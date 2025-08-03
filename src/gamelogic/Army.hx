package gamelogic;

import gamelogic.physics.PhysicalWorld;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2CircleShape;
import gamelogic.physics.PhysicalWorld.PHYSICSCALEINVERT;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2BodyDef;
import h3d.Vector;
import utilities.Vector2D;
import gamelogic.physics.PhysicalWorld.PHYSICSCALE;
import graphics.TweenManager;
import graphics.TweenManager.DelayedCallTween;
import utilities.RNGManager;
import gamelogic.Corpse;
import graphics.Footsteps;
import h2d.Graphics;
import utilities.MessageManager;
import h2d.Object;
import gamelogic.Location;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;

enum ArmyState {
    Idle;
    Planning;
    Marching;
    AwaitingPickup;
    Battling;
}

class Army implements Updateable implements MessageListener {

    public var range(get, null): Int;
    public var rangeLeft(get, null): Int;
    public var route = new Array<Location>();
    public var graphics: Graphics;
    public var footsteps: Graphics;
    public var state: ArmyState;
    static public var singleton: Army;
    public var lastLocation(get, null): Location;
    var necromancer: Necromancer;

    public var units = new Array<Unit>();
    public var corpses = new Array<Corpse>();

    var pendingCollections = 0;

    public var defeats = 0;
    
    public function new(p: Object) {
        singleton = this;
        MessageManager.addListener(this);
        graphics = new Graphics(p);
        footsteps = new Graphics(graphics);
        state = Idle;
        route.push(HQTower.singleton);
        necromancer = new Necromancer(graphics);
        units.push(necromancer);
        // DEBUG
        //  for (_ in 0...2) {
        //     var body_definition = new B2BodyDef();
        //     body_definition.type = B2BodyType.DYNAMIC_BODY;
        //     body_definition.position = new Vector2D();
        //     body_definition.linearDamping = 1;
        //     var circle = new B2CircleShape(10*PHYSICSCALEINVERT);
        //     var fixture_definition = new B2FixtureDef();
        //     fixture_definition.shape = circle;
        //     fixture_definition.userData = this;
        //     fixture_definition.density = 10;
        //     var body = PhysicalWorld.gameWorld.createBody(body_definition);
        //     body.createFixture(fixture_definition);

        //     units.push(new Skeleton(graphics, necromancer, body));
        // }
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, TurnComplete)) {
            state = Idle;
            necromancer.state = Idle;
        }
        if (Std.isOfType(msg, LocationSelected)) {
            var params = cast(msg, LocationSelected);
            for (l in route) l.highlightRoads = false;
            if (params.location.id == Location.hqID) {
                if (state == Idle && params.location.id == Location.hqID) {
                    state = Planning;
                    params.location.highlightRoads = true;
                }
                else if (state == Planning) {
                    route.push(params.location);
                    MessageManager.sendMessage(new March());
                    state = Marching;
                }
            } else {
                route.push(params.location);
                params.location.highlightRoads = true;
            }
            MessageManager.sendMessage(new ResetOrb());
        }
        if (Std.isOfType(msg, LocationDeselected)) {
            var params = cast(msg, LocationDeselected);
            var l = route.pop();
            l.highlightRoads = false;
            l.highlight.visible = false;
            l.selected = false;
            while (l != params.location) {
                l.highlightRoads = false;
                l.highlight.visible = false;
                l.selected = false;
                l = route.pop();
            }
            route[route.length-1].highlightRoads = true;
            if (state == Planning && params.location.id == Location.hqID)
                state = Idle;
            MessageManager.sendMessage(new ResetOrb());
        }
        if (Std.isOfType(msg, CorpsePickup)) {
            pendingCollections--;
        }
        if (Std.isOfType(msg, CorpseDestroyed)) {
            var params = cast(msg, CorpseDestroyed);
            corpses.remove(params.corpse);
        }
        if (Std.isOfType(msg, NewUnit)) {
            var params = cast(msg, NewUnit);
            if (params.corpse.type == ZombieCorpse)
                units.push(new Zombie(graphics, necromancer, params.corpse.body));
            else if (params.corpse.type == SkeletonCorpse)
                units.push(new Skeleton(graphics, necromancer, params.corpse.body));
            else if (params.corpse.type == PeasantCorpse)
                units.push(new Zombie(graphics, necromancer, params.corpse.body, true));
        }
        if (Std.isOfType(msg, UnitDeath)) {
            // trace("friendly death");
            // trace("enemies",route[0].enemies.length);
            // trace("units",units.length);
            // cancel any pending corpse pickups
            pendingCollections = 0;
            var u = cast(msg, UnitDeath).unit;
            units.remove(u);
            if (u.corpse != null)
                route[0].corpses.push(u.corpse);
            var p: Vector2D = u.body.getPosition();
            p *= PHYSICSCALE;
            route[0].generateCorpse(p, u);
            u.destroy();
            // reshuffle combatants
            if (state == Battling)
                battle();
        }
        if (Std.isOfType(msg, EnemyDeath)) {
            // trace("enemy death");
            // trace("enemies",route[0].enemies.length);
            // trace("units",units.length);
            // reshuffle combatants
            if (state == Battling)
                battle();
        }
        return false;
    }

    public function progress() {
        route.remove(route[0]);
        if (route.length == 1) {
            // assume it must be the tower
            for (u in units) {
                if (u.corpse != null) {
                    u.corpse.resurrect();
                    corpses.push(u.corpse);
                    u.corpse = null;
                }
            }
            TweenManager.singleton.add(new DelayedCallTween(() -> MessageManager.sendMessage(new TurnComplete()), -3, 0));
        } else {
            if (Std.isOfType(route[0], Graveyard)) {
                for (_ in 0...RNGManager.rand.random(2) + 1)
                    route[0].generateCorpse();
                // Collect Corpses
                collectCorpses();
                // Continue
            } if (route[0].enemies.length > 0) {
                battle();
            }
            // if (Std.isOfType(route[0], Farm)) {
            //     // Battle
            //     battle();
            //     // Collect Corpses
            //     // Continue
            //     // resolve the area
            // }
        }
    }

    function collectCorpses() {
        state = AwaitingPickup;
        pendingCollections = 0;
        for (u in units) {
            if (u.corpse == null && route[0].corpses.length > 0) {
                var c = route[0].corpses.pop();
                u.fetchCorpse(c);
                u.corpse = c;
                pendingCollections++;
            }
        }
        // trace("collection corpses", pendingCollections);
    }

    function battle() {
        // trace("army battling");
        // Defeat
        if (units.length == 1) {
            // trace("defeat");
            MessageManager.sendMessage(new LostBattle());
            TweenManager.singleton.add(new DelayedCallTween( () -> MessageManager.sendMessage(new TurnComplete()), -5, 0));
            defeats++;
            // TODO fade to black and back
            if (necromancer.corpse != null) {
                route[0].corpses.push(necromancer.corpse);
                necromancer.corpse.detach();
                necromancer.corpse = null;
            }
            route = new Array<Location>();
            route.push(HQTower.singleton);
            necromancer.state = Idle;
            state = Idle;
            necromancer.destination = new Vector2D();
            return;
        }
        // Victory
        if (route[0].enemies.length == 0) {
            // trace("victory");
            for (u in units)
                u.state = Idle;
            collectCorpses();
            return;
        }
        state = Battling;
        var friendlies = units.copy();
        friendlies.remove(necromancer);
        // trace("f", friendlies.length);
        RNGManager.rand.shuffle(friendlies);
        var enemies = route[0].enemies.copy();
        // trace("e", enemies.length);
        RNGManager.rand.shuffle(enemies);
        for (u in units) {
            if (enemies.length == 0) {
                enemies = route[0].enemies.copy();
                RNGManager.rand.shuffle(enemies);
            }
            var e = enemies.pop();
            u.attack(e);
        }
        for (e in enemies) {
            if (friendlies.length == 0) {
                friendlies = units.copy();
                RNGManager.rand.shuffle(friendlies);
            }
            var f = friendlies.pop();
            e.attack(f);
        }
    }

    public function update(dt:Float) {
        graphics.clear();
        footsteps.remove();
        footsteps = new Graphics(graphics);
        if (state == Planning) {
            var prev = route[0];
            for (i in 1...route.length) {
                new Footsteps(footsteps, prev.position, route[i].position);
                prev = route[i];
            }
        } if (state == AwaitingPickup) {
            if (pendingCollections == 0) {
                state = Marching;
                MessageManager.sendMessage(new March());
            }
        }
        for (u in units) u.update(dt);
        for (c in corpses) c.update(dt);
    }

    public function get_lastLocation() : Location {
        return route[route.length-1];
    }

    function get_rangeLeft():Int {
        return range - route.length + 1;
    }

    function get_range() : Int {
        var num_zombs = 0;
        var num_skele = 0;
        for (u in units) {
            if (Std.isOfType(u, Skeleton)) num_skele++;
            if (Std.isOfType(u, Zombie)) num_zombs++;
        }
        var zomb_thresholds = [1, 5, 10, 50, 100];
        var zomb_bonus = [0, 1, 2, 3, 4, 5];
        var skele_thresholds = [1, 3, 10, 30, 100];
        var skele_bonus = [0, 2, 4, 8, 16, 32];
        var z_index = 0;
        var s_index = 0;
        while (num_zombs > 0) {
            z_index++;
            num_zombs -= zomb_thresholds[z_index];
        }
        while (num_skele > 0) {
            s_index++;
            num_skele -= skele_thresholds[s_index];
        }
        return 2 + zomb_bonus[z_index] + skele_bonus[s_index];
    }

    public static function canReturnHomeFrom(r:Int, route: Array<Location>, l:Location) {
        // trace(r, route.length, l.id, l.id == Location.hqID);
        if (route.length == 1) return true;
        if (l.id == Location.hqID && r >= 0) return true;
        if (r <= 0) return false;
        if (route.contains(l)) return false;
        var n_route = route.copy();
        n_route.push(l);
        for (n in l.neighbours) {
            if (n.id == Location.hqID) return true;
            if (route.contains(n)) continue;
            if (canReturnHomeFrom(r-1, n_route, n)) return true;
        }
        return false;
    }
}
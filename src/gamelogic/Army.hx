package gamelogic;

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
}

class Army implements Updateable implements MessageListener {

    var range(get, null): Int;
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
    
    public function new(p: Object) {
        singleton = this;
        MessageManager.addListener(this);
        graphics = new Graphics(p);
        footsteps = new Graphics(graphics);
        state = Idle;
        route.push(HQTower.singleton);
        necromancer = new Necromancer(graphics);
        units.push(necromancer);
    }

    public function receiveMessage(msg:Message):Bool {
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
        }
        return false;
    }

    public function progress() {
        route.remove(route[0]);
        if (route.length == 1) {
            // assume it must be the tower
            state = Idle;
            necromancer.state = Idle;
            for (u in units) {
                if (u.corpse != null) {
                    u.corpse.resurrect();
                    corpses.push(u.corpse);
                    u.corpse = null;
                }
            }
            MessageManager.sendMessage(new TurnComplete());
        } else {
            if (Std.isOfType(route[0], Graveyard)) {
                for (_ in 0...RNGManager.rand.random(2) + 1)
                    route[0].generateCorpse(graphics);
                // Collect Corpses
                collectCorpses();
                // Continue
            } if (Std.isOfType(route[0], Farm)) {
                // Battle
                // Collect Corpses
                // Continue
                // MessageManager.sendMessage(new March());
            }
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
    }

    public function update(dt:Float) {
        graphics.clear();
        footsteps.remove();
        footsteps = new Graphics(graphics);
        if (state == Planning) {
            // TODO visualise neighbours
            // graphics.beginFill(0xFF0000, 0.1);
            // graphics.drawCircle(lastLocation.position.x, lastLocation.position.y, rangeLeft);
            // graphics.endFill();

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
        if (l.id == Location.hqID) return true;
        if (route.length == 1) return true;
        if (r <= 0)
            return false;
        // trace(l.neighbours);
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
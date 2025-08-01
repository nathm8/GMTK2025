package gamelogic;

import utilities.RNGManager;
import gamelogic.Unit.Corpse;
import graphics.Footsteps;
import h2d.Graphics;
import utilities.MessageManager;
import h2d.Object;
import gamelogic.Map.Location;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;

enum ArmyState {
    Idle;
    Planning;
    Marching;
}

class Army implements Updateable implements MessageListener {

    var range = 1500;
    public var route = new Array<Location>();
    public var graphics: Graphics;
    public var footsteps: Graphics;
    public var state: ArmyState;
    static public var singleton: Army;
    public var lastLocation(get, null): Location;
    public var rangeLeft(get, null): Float;
    var necromancer: Necromancer;

    public var units = new Array<Unit>();
    public var corpses = new Array<Corpse>();
    
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
            if (params.location.id == 0) {
                if (state == Idle && params.location.id == 0)
                    state = Planning;
                else if (state == Planning) {
                    route.push(params.location);
                    MessageManager.sendMessage(new March());
                    state = Marching;
                }
            } else {
                route.push(params.location);
            }
        }
        if (Std.isOfType(msg, LocationDeselected)) {
            var params = cast(msg, LocationDeselected);
            route.remove(params.location);
            if (state == Planning && params.location.id == 0)
                state = Idle;
        }
        if (Std.isOfType(msg, CorpseDestroyed)) {
            var params = cast(msg, CorpseDestroyed);
            corpses.remove(params.corpse);
        }
        if (Std.isOfType(msg, NewUnit)) {
            var params = cast(msg, NewUnit);
            if (params.corpse.type == ZombieCorpse)
                units.push(new Zombie(graphics, necromancer, params.corpse.body));
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
                    u.corpse = null;
                }
            }
        } else {
            if (Std.isOfType(route[0], Graveyard)) {
                // TODO limit number of corpses available at each graveyard
                var num_corpses = RNGManager.rand.random(2) + 1;
                for (u in units) {
                    if (u.corpse == null) {
                        u.corpse = new Corpse(graphics, u.body);
                        corpses.push(u.corpse);
                        num_corpses--;
                        if (num_corpses == 0) break;
                    }
                }
            }
            MessageManager.sendMessage(new March());
        }
    }

    public function update(dt:Float) {
        graphics.clear();
        footsteps.remove();
        footsteps = new Graphics(graphics);
        if (state == Planning) {
            graphics.beginFill(0xFF0000, 0.1);
            graphics.drawCircle(lastLocation.position.x, lastLocation.position.y, rangeLeft);
            graphics.endFill();

            var prev = route[0];
            for (i in 1...route.length) {
                new Footsteps(footsteps, prev.position, route[i].position);
                prev = route[i];
            }
        }
        for (u in units) u.update(dt);
        for (c in corpses) c.update(dt);
    }

    public function get_lastLocation() : Location {
        return route[route.length-1];
    }

    function get_rangeLeft():Float {
        var c = 0.0;
        var last = route[0];
        for (l in route) {
            c += last.position.distanceTo(l.position);
            last = l;
        }
        return range - c;
    }
}
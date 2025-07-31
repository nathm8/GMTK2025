package gamelogic;

import graphics.Footsteps;
import h2d.Tile;
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
    var route = new Array<Location>();
    public var graphics: Graphics;
    public var state: ArmyState;
    static public var singleton: Army;
    public var lastLocation(get, null): Location;
    public var rangeLeft(get, null): Float;
    
    public function new(p: Object) {
        singleton = this;
        MessageManager.addListener(this);
        graphics = new Graphics(p);
        state = Idle;
        route.push(HQTower.singleton);
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, LocationSelected)) {
            var params = cast(msg, LocationSelected);
            route.push(params.location);
        }
        if (Std.isOfType(msg, LocationDeselected)) {
            var params = cast(msg, LocationDeselected);
            route.remove(params.location);
        }
        return false;
    }

    public function update(dt:Float) {
        graphics.clear();
        graphics.removeChildren();
        if (state != Marching) {
            graphics.beginFill(0xFF0000, 0.1);
            graphics.drawCircle(lastLocation.position.x, lastLocation.position.y, rangeLeft);
            graphics.endFill();

            var prev = route[0];
            for (i in 1...route.length) {
                new Footsteps(graphics, prev.position, route[i].position);
                prev = route[i];
            }
        }
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
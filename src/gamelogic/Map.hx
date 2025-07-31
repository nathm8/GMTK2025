package gamelogic;

import utilities.RNGManager;
import utilities.Vector2D;
import h2d.Graphics;
import h2d.Object;
import utilities.MessageManager;

class Location implements Updateable implements MessageListener {
    public var position: Vector2D;

    public function receiveMessage(msg:Message):Bool {
        throw new haxe.exceptions.NotImplementedException();
    }

	public function update(dt:Float) {}
}

class Map implements Updateable implements MessageListener {
 
    public var graphics: Graphics;
    public var locations = new Array<Location>();

    public function receiveMessage(msg:Message):Bool {
		return false;
	}
    
    public function new(p: Object) {
        MessageManager.addListener(this);
        graphics = new Graphics(p);
        locations.push(new HQTower(graphics));
        for (_ in 0...50) {
            var unique_location = false;
            var p = new Vector2D();
            while (!unique_location) {
                unique_location = true;
                var x = RNGManager.rand.random(2000) - 1000;
                var y = RNGManager.rand.random(2000) - 1000;
                p = new Vector2D(x, y);
                for (l in locations) {
                    if (l.position.distanceTo(p) < 100) {
                        unique_location = false;
                        break;
                    }
                }
            }
            locations.push(new Graveyard(graphics, p));
        }
    }

    public function update(dt: Float) {
    }
}
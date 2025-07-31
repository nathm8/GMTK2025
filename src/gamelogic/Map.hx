package gamelogic;

import h3d.Vector;
import h3d.Vector4;
import h2d.Bitmap;
import utilities.RNGManager;
import utilities.Vector2D;
import h2d.Graphics;
import h2d.Object;
import utilities.MessageManager;

class Location implements Updateable implements MessageListener {
    static var maxID = 0;
    public var id: Int;
    public var position: Vector2D;
    public var highlight: Graphics;
    public var selected = false;

    public function new(p: Object) {
        id = maxID++;
        highlight = new Graphics(p);
        new Bitmap(hxd.Res.img.target.toTile().center(), highlight);
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, MouseMoveMessage)) {
            var params = cast(msg, MouseMoveMessage);
            if (position.distanceTo(params.worldPosition) < 100)
                highlight.visible = true || selected;
            else
                highlight.visible = false || selected;
        }
        if (Std.isOfType(msg, MouseReleaseMessage)) {
            var params = cast(msg, MouseReleaseMessage);
            if (position.distanceTo(params.worldPosition) < 100) {
                if (selected) {
                    selected = false;
                    highlight.visible = false;
                    highlight.rotation = 0;
                } else {
                    selected = true;
                    highlight.visible = true;
                    highlight.rotation = Math.PI/4;
                }
            }
        }
        return false;
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
                    if (l.position.distanceTo(p) < 200) {
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
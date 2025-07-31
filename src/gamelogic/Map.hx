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
    public var targetSelected: Bitmap;
    public var selected = false;

    public function new(p: Object) {
        id = maxID++;
        highlight = new Graphics(p);
        new Bitmap(hxd.Res.img.target.toTile().center(), highlight);
        targetSelected = new Bitmap(hxd.Res.img.targetselected.toTile().center(), highlight);
        targetSelected.visible = false;
        highlight.visible = false;
        MessageManager.addListener(this);
    }

    public function receiveMessage(msg:Message):Bool {
        if (Army.singleton == null) return false;
        if (Army.singleton.state == Marching) return false;
        if (Army.singleton.state == Idle && id != 0) return false;
        if (Std.isOfType(msg, MouseMove)) {
            var params = cast(msg, MouseMove);
            if (position.distanceTo(Army.singleton.lastLocation.position) > Army.singleton.rangeLeft)
                return false;
            if (position.distanceTo(params.worldPosition) < 100)
                highlight.visible = true || selected;
            else
                highlight.visible = false || selected;
        }
        if (Std.isOfType(msg, MouseRelease)) {
            var params = cast(msg, MouseRelease);
            if (!selected && position.distanceTo(Army.singleton.lastLocation.position) > Army.singleton.rangeLeft)
                return false;
            if (position.distanceTo(params.worldPosition) < 100) {
                if (selected) {
                    selected = false;
                    highlight.visible = false;
                    targetSelected.visible = false;
                    highlight.rotation = 0;
                    MessageManager.sendMessage(new LocationDeselected(this));
                } else {
                    selected = true;
                    highlight.visible = true;
                    highlight.rotation = Math.PI/4;
                    targetSelected.visible = true;
                    if (id == 0 && Army.singleton.state == Idle) {
                        selected = false;
                        highlight.visible = false;
                    }
                    MessageManager.sendMessage(new LocationSelected(this));
                }
            }
        }
        if (Std.isOfType(msg, March)) {
            selected = false;
            highlight.visible = false;
            targetSelected.visible = false;
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
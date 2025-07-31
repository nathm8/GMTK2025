package gamelogic;

import gamelogic.Map.Location;
import h2d.Graphics;
import h2d.Object;
import h2d.Bitmap;
import utilities.Vector2D;
import utilities.MessageManager;

class HQTower extends Location {
 
    public var graphics: Graphics;

    public override function receiveMessage(msg:Message):Bool {
        super.receiveMessage(msg);
		return false;
	}
    
    public function new(p: Object) {
        MessageManager.addListener(this);
        graphics = new Graphics(p);
        position = new Vector2D();
        new Bitmap(hxd.Res.img.tower.toTile().center(), graphics);
        super(graphics);
    }

    public override function update(dt: Float) {
    }
}
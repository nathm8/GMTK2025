package gamelogic;

import gamelogic.Location;
import h2d.Graphics;
import h2d.Object;
import h2d.Bitmap;
import utilities.Vector2D;
import utilities.MessageManager;

class HQTower extends Location {
 
    public var graphics: Graphics;
    static public var singleton: HQTower;

    public override function receiveMessage(msg:Message):Bool {
        super.receiveMessage(msg);
		return false;
	}
    
    public function new(p: Object) {
        singleton = this;
        graphics = new Graphics(p);
        position = new Vector2D();
        new Bitmap(hxd.Res.img.tower.toTile().center(), graphics);
        super(graphics);
        graphics.y = -50;
    }

    public override function update(dt: Float) {
        super.update(dt);
    }
}
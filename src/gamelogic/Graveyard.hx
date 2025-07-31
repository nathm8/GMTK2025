package gamelogic;

import gamelogic.Map.Location;
import h2d.Graphics;
import h2d.Object;
import h2d.Bitmap;
import utilities.Vector2D;
import utilities.MessageManager;

class Graveyard extends Location {
 
    public var graphics: Graphics;

    public override function receiveMessage(msg:Message):Bool {
        super.receiveMessage(msg);
		return false;
	}
    
    public function new(p: Object, pos: Vector2D) {
        MessageManager.addListener(this);
        graphics = new Graphics(p);
        position = pos;
        graphics.x = pos.x;
        graphics.y = pos.y;
        new Bitmap(hxd.Res.img.graveyard.toTile().center(), graphics);
        super(graphics);
    }

    public  override function update(dt: Float) {
    }
}
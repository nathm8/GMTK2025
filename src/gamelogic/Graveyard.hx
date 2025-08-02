package gamelogic;

import gamelogic.Location;
import h2d.Object;
import h2d.Bitmap;
import utilities.Vector2D;
import utilities.MessageManager;

class Graveyard extends Location {
 
    public override function receiveMessage(msg:Message):Bool {
        super.receiveMessage(msg);
		return false;
	}
    
    public function new(p: Object, pos: Vector2D, i: Int, n: Array<Int>, m: Map) {
        super(p, i, n, m);
        position = pos;
        graphics.x = pos.x;
        graphics.y = pos.y;
        new Bitmap(hxd.Res.img.graveyard.toTile().center(), graphics);
    }

    public override function update(dt: Float) {
        super.update(dt);
    }
}
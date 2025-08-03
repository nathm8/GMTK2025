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
        var highlight_bmp = new Bitmap(hxd.Res.img.locationblur.toTile().center(), highlight);
        super(p, i, n, m, highlight_bmp);
        position = pos;
        graphics.x = pos.x;
        graphics.y = pos.y;
        var bmp = new Bitmap(hxd.Res.img.graveyard.toTile().center(), graphics);
        bmp.scale(0.5);
    }

    public override function update(dt: Float) {
        super.update(dt);
    }
}
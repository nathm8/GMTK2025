package gamelogic;

import gamelogic.Location;
import h2d.Graphics;
import h2d.Object;
import h2d.Bitmap;
import utilities.Vector2D;
import utilities.MessageManager;

class HQTower extends Location {
 
    static public var singleton: HQTower;

    public override function receiveMessage(msg:Message):Bool {
        super.receiveMessage(msg);
		return false;
	}
    
    public function new(p: Object, i: Int, n: Array<Int>, m: Map) {
        var highlight_bmp = new Bitmap(hxd.Res.img.towerblur.toTile().center(), highlight);
        super(p, i, n, m, highlight_bmp);
        Location.hqID = i;
        singleton = this;
        position = new Vector2D();
        var bmp = new Bitmap(hxd.Res.img.tower.toTile().center(), graphics);
    }

    public override function update(dt: Float) {
        super.update(dt);
    }
}
package gamelogic;

import utilities.RNGManager;
import gamelogic.Map.Location;
import h2d.Graphics;
import h2d.Object;
import h2d.Bitmap;
import utilities.Vector2D;
import utilities.MessageManager;

class Farm extends Location {
 
    public var graphics: Graphics;
    var peasants = new Array<Peasant>();

    public override function receiveMessage(msg:Message):Bool {
        super.receiveMessage(msg);
		return false;
	}
    
    public function new(p: Object, pos: Vector2D) {
        graphics = new Graphics(p);
        position = pos;
        graphics.x = pos.x;
        graphics.y = pos.y;
        new Bitmap(hxd.Res.img.farm.toTile().center(), graphics);
        super(graphics);

        for (_ in 0...RNGManager.rand.random(5)+1) {
            peasants.push(new Peasant(graphics.parent, this));
        }
    }

    public  override function update(dt: Float) {
        for (p in peasants) p.update(dt);
    }
}
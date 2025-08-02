package graphics.ui;

import utilities.MessageManager;
import utilities.MessageManager.MessageListener;
import h2d.col.Point;
import h2d.Camera;
import gamelogic.Updateable;
import h2d.Bitmap;
import h2d.Object;

class ManaOrb extends Object implements Updateable implements MessageListener {

	var camera: Camera;
	var mana: Bitmap;
	public function new(p :Object, c: Camera) {
		super(p);
		camera = c;
		var orb = new Bitmap(hxd.Res.img.orb.toTile().center(), this);
		var mask_area = new Bitmap(hxd.Res.img.orbmask.toTile().center(), orb);
		mana = new Bitmap(hxd.Res.img.mana.toTile().center(), orb);
		mana.y = 190;
		// 20 = full
		// 190 = empty
		mana.tileWrap = true;
		mana.tile.scrollDiscrete(0, -1);
		var orbouter = new Bitmap(hxd.Res.img.orbouter.toTile().center(), orb);

		var mask = new h2d.filter.Mask(mask_area);
		mana.filter = mask;

		MessageManager.addListener(this);
	}

	public function update(dt:Float) {
		var p = new Point(1920*0.1, 1080*0.85);
		camera.screenToCamera(p);
		x = p.x;
		y = p.y;
		mana.tile.scrollDiscrete(50*dt, 0);
	}

	public function receiveMessage(msg:Message):Bool {
		return false;
	}
}

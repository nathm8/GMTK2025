package graphics.ui;

import gamelogic.Army;
import h2d.Graphics;
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
	var orb: Bitmap;
	var measures: Graphics;
	var measurePercentages = new Array<Float>();

	public function new(p :Object, c: Camera) {
		super(p);
		camera = c;
		orb = new Bitmap(hxd.Res.img.orb.toTile().center(), this);
		var mask_area = new Bitmap(hxd.Res.img.orbmask.toTile().center(), orb);
		mana = new Bitmap(hxd.Res.img.mana.toTile().center(), orb);
		mana.y = 10;
		// 10 = full
		// 190 = empty
		mana.tileWrap = true;
		mana.tile.scrollDiscrete(0, -1);
		measures = new Graphics(orb);
		var orbouter = new Bitmap(hxd.Res.img.orbouter.toTile().center(), orb);

		var mask = new h2d.filter.Mask(mask_area);
		mana.filter = mask;
		measures.filter = mask;

		calcMeasurements();
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
		if (Std.isOfType(msg, TurnComplete)) {
			calcMeasurements();
		}
		if (Std.isOfType(msg, LocationSelected)) {
		return false;
	}

	function calcMeasurements() {
		measures.clear();
		measures.lineStyle(5, 0x000000);
		measurePercentages = new Array<Float>();
		var lines = Army.singleton.range;
		var lines = 4;
		for (y in 1...lines) {
			var r = y/lines;
			measurePercentages.push(r);
			measures.moveTo(10+25*y%2, 100*(1-r) + -130*r);
			measures.lineTo(100, 100*(1-r) + -130*r);
		}
	}
}

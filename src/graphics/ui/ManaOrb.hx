package graphics.ui;

import h2d.Layers;
import graphics.TweenManager.MoveBounceTween;
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

	var mana: Bitmap;
	var orb: Bitmap;
	var measures: Graphics;
	var measurePercentages = new Array<Float>();

	public function new() {
		super();
		var mask_area = new Bitmap(hxd.Res.img.orbmask.toTile().center(), this);
		mana = new Bitmap(hxd.Res.img.mana.toTile().center(), this);
		orb = new Bitmap(hxd.Res.img.orb.toTile().center(), this);
		mana.y = 10;
		// 10 = full
		// 190 = empty
		mana.tileWrap = true;
		mana.tile.scrollDiscrete(0, -1);
		measures = new Graphics(orb);

		var mask = new h2d.filter.Mask(mask_area);
		mana.filter = mask;
		// mana.alpha = 0.75;
		measures.filter = mask;
		x = 128;
		y = 720-256+128;

		calcMeasurements();
		MessageManager.addListener(this);
	}

	public function update(dt:Float) {
		mana.tile.scrollDiscrete(50*dt, 0);
	}

	public function receiveMessage(msg:Message):Bool {
		if (Std.isOfType(msg, TurnComplete)) {
			calcMeasurements();
			lerpMana();
		}
		if (Std.isOfType(msg, ResetOrb)) {
			lerpMana();
		}
		return false;
	}

	function lerpMana() {
		var r = measurePercentages[Army.singleton.rangeLeft];
		TweenManager.singleton.add(new MoveBounceTween(mana, {x:mana.x, y:mana.y}, {x:mana.x, y:(1-r)*190 + r*10}, 0, 0.5));
	}

	function calcMeasurements() {
		measures.clear();
		measures.lineStyle(2.5, 0x000000);
		measurePercentages = new Array<Float>();
		measurePercentages.push(0);
		var lines = Army.singleton.range;
		for (y in 1...lines) {
			var r = y/lines;
			measurePercentages.push(r);
			measures.moveTo(10, 100*(1-r) + -130*r);
			// measures.moveTo(10+25*y%2, 100*(1-r) + -130*r);
			measures.lineTo(100, 100*(1-r) + -130*r);
		}
		measurePercentages.push(1);
	}
}

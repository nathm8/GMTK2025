package gamelogic;

import h2d.Camera;
import utilities.Vector2D;
import graphics.ui.ManaOrb;
import h2d.Scene;
import h2d.Text;
import h2d.col.Point;
import hxd.Key;
import hxd.Timer;
import gamelogic.Updateable;
import gamelogic.physics.PhysicalWorld;
import graphics.TweenManager;
import utilities.MessageManager;

class GameScene extends Scene implements MessageListener {
	var updateables = new Array<Updateable>();
	var fpsText: Text;
	var cameraScale = 1.0;
	var lastMousePos: Vector2D;

	public function new() {
		super();
		fpsText = new h2d.Text(hxd.res.DefaultFont.get());
		fpsText.visible = true;
		defaultSmooth = true;
		camera.anchorX = 0.5;
		camera.anchorY = 0.5;
		camera.layerVisible = (l) -> l != 2;

		var ui_camera = new Camera();
		ui_camera.layerVisible = (l) -> l == 2;
		addCamera(ui_camera);

		MessageManager.addListener(this);

		
		updateables.push(new Map(this));
		updateables.push(new Army(this));
		var o = new ManaOrb();
		add(o, 2);
		add(fpsText, 2);
		updateables.push(o);
	}
	
	public function update(dt:Float) {
		// trace("GSU: start");
		PhysicalWorld.update(dt);
		// trace("GSU: world");
		cameraControl();
		for (u in updateables)
			u.update(dt);
		// trace("GSU: updates");
		fpsText.text = Std.string(Math.round(Timer.fps()));

		TweenManager.singleton.update(dt);
	}

	public function receiveMessage(msg:Message):Bool {
		if (Std.isOfType(msg, MouseMove)) {
			lastMousePos = cast(msg, MouseMove).worldPosition;
		}
		return false;
	}

	function cameraControl() {
		// if (Key.isDown(Key.A))
		// 	camera.move(-10,0);
		// if (Key.isDown(Key.D))
		// 	camera.move(10,0);
		// if (Key.isDown(Key.W))
		// 	camera.move(0,-10);
		// if (Key.isDown(Key.S))
		// 	camera.move(0,10);
		// if (Key.isDown(Key.E))
		// 	cameraScale *= 1.1;
		// if (Key.isDown(Key.Q))
		// 	cameraScale *= 0.9;
		// camera.setScale(cameraScale, cameraScale);
		// fpsText.setScale(1 / cameraScale);

		// TODO, look-ahead when planning

		var pos = new Vector2D(camera.x, camera.y);
		var centre = Necromancer.cameraPos;
		if (Army.singleton.state == Planning) {
			// centre = Army.singleton.route[Army.singleton.route.length-1].position;
			centre = lastMousePos;
		}
		if ((pos - centre).magnitude > 50) {
			camera.x = centre.x*0.01 + camera.x*0.99;
			camera.y = centre.y*0.01 + camera.y*0.99;
		}
	}

}

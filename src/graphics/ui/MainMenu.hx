package graphics.ui;

import graphics.TweenManager.FadeOutTween;
import graphics.TweenManager.DelayedCallTween;
import graphics.TweenManager.LinearMoveTween;
import utilities.Vector2D;
import utilities.RNGManager;
import graphics.ui.ButtonWithText;
import h2d.Bitmap;
import h2d.Object;
import h2d.Scene;

class MainMenu extends Scene {

	var allArt = new Array<Bitmap>();
	var toShow = new Array<Bitmap>();
	var dircs = new Array<Vector2D>();
	var WIDTH = 1280;
	var HEIGHT = 720;

	public function new(startGame:() -> Void) {
		super();
        // var WIDTH = 1920;
        // var HEIGHT = 1080;
		// graphics
		var visuals = new Object(this);
		// var visual = new Bitmap(hxd.Res.img.Title.toTile().center(), visuals);
		// visual.x = WIDTH / 2;
		// visual.y = HEIGHT / 2;

		// Art
		allArt.push(new Bitmap(hxd.Res.img.gallery.King_FullArt_1.toTile(), visuals));
		allArt.push(new Bitmap(hxd.Res.img.gallery.Skeletons_FullArt_1.toTile(), visuals));
		allArt.push(new Bitmap(hxd.Res.img.gallery.Zombie_FullArt_1.toTile(), visuals));
		for (a in allArt) a.visible = false;
		newArt();

		// title
		var titleText = new h2d.Text(hxd.res.DefaultFont.get(), visuals);
		titleText.x = width / 2;
		titleText.y = 2 * height / 10;
		titleText.text = "The Travelling Necromancer Problem";
		titleText.textAlign = Center;
		titleText.dropShadow = {dx:1, dy:1, color: 0x000000, alpha:1};
		titleText.setScale(5);

		// buttons
		var playButton = new BackgroundButtonWithText("Play", this, () -> startGame());
		playButton.x = width / 2;
		playButton.y = 3* height / 4;
		playButton.scale(2);
		// playButton.color = Vector.fromColor(0xffffff00);
		playButton.textObject.scale(2);
		playButton.textObject.y = -18;
		// playButton.textObject.color = Vector.fromColor(0);
		playButton.textObject.text = "Begin";
	}

	function newArt() {
		if (toShow.length == 0)
			toShow = allArt.copy();
		if (dircs.length == 0) {
			dircs = [new Vector2D(-200,-200),
					new Vector2D( 200,-200),
					new Vector2D(-200,200),
					new Vector2D(200,200)];
		}
		RNGManager.rand.shuffle(dircs);
		RNGManager.rand.shuffle(toShow);
		var art = toShow.pop();
		art.alpha = 1;
		art.visible = true;
		var end = dircs.pop();
		art.x = 0; art.y = 0;
		// art.x = WIDTH/2; art.y = HEIGHT/2;
		trace(dircs, end);
		TweenManager.singleton.add(new LinearMoveTween(art, {x:0, y:0}, end, 0, 8));
		TweenManager.singleton.add(new FadeOutTween(art, -7, 1));
		TweenManager.singleton.add(new DelayedCallTween(newArt, -9, 0));
	}

	public function update(dt:Float) {
		TweenManager.singleton.update(dt);
	}
}

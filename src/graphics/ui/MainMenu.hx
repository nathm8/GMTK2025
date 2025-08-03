package graphics.ui;

import graphics.ui.ButtonWithText;
import h2d.Bitmap;
import h2d.Object;
import h2d.Scene;

class MainMenu extends Scene {
	public function new(startGame:() -> Void) {
		super();
        var WIDTH = 1280;
        var HEIGHT = 720;
        // var WIDTH = 1920;
        // var HEIGHT = 1080;
		// graphics
		var visuals = new Object(this);
		var visual = new Bitmap(hxd.Res.img.Title.toTile().center(), visuals);
		visual.x = WIDTH / 2;
		visual.y = HEIGHT / 2;

		// title
		var titleText = new h2d.Text(hxd.res.DefaultFont.get(), visuals);
		titleText.x = width / 2;
		titleText.y = 2 * height / 10;
		titleText.text = "The Travelling Necromancer Problem";
		titleText.textAlign = Center;
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
}

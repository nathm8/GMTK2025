package graphics;

import utilities.MessageManager;
import graphics.TweenManager.FadeOutTween;
import graphics.TweenManager.FadeInTween;
import h2d.Text;
import utilities.MessageManager.LostBattle;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
import h2d.Bitmap;
import utilities.Vector2D;
import h2d.Object;
import h2d.Graphics;

class DefeatScreen extends Graphics implements MessageListener {
    
    var defeatText: Text;
    var forNowText: Text;

    public function new(p: Object) {
        super(p);
        var WIDTH = 1920;
        var HEIGHT = 1080;
        beginFill(0x000000);
        addVertex(0, 0, 0, 0 ,0, 1);
        addVertex(WIDTH, 0, 0, 0 ,0, 1);
        addVertex(WIDTH, HEIGHT, 0, 0 ,0, 1);
        addVertex(0, HEIGHT, 0, 0 ,0, 1);
        addVertex(0, 0, 0, 0 ,0, 1);
        alpha = 0;
        smooth = false;

        defeatText = new Text(hxd.res.DefaultFont.get(), this);
        defeatText.scale(5);
		defeatText.x = WIDTH/2;
		defeatText.y = HEIGHT/2 - 100;
		defeatText.text = "Defeat!";
		defeatText.textAlign = Center;

        forNowText = new Text(hxd.res.DefaultFont.get(), this);
        forNowText.scale(5);
		forNowText.x = WIDTH/2;
		forNowText.y = HEIGHT/2;
		forNowText.text = "...for now";
		forNowText.textAlign = Center;
        forNowText.alpha = 0;

        MessageManager.addListener(this);
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, LostBattle)) {
            TweenManager.singleton.add(new FadeInTween(this, 0, 5));
            TweenManager.singleton.add(new FadeInTween(forNowText, -3, 2));
            TweenManager.singleton.add(new FadeOutTween(this, -5, 1.5));
        }
        return false;
    }
}
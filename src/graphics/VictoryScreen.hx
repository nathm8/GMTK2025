package graphics;

import gamelogic.Army;
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

class VictoryScreen extends Graphics implements MessageListener {
    
    var defeatText: Text;
    var forNowText: Text;

    public function new(p: Object) {
        super(p);
        var WIDTH = 1280;
        var HEIGHT = 720;
        // var WIDTH = 1920;
        // var HEIGHT = 1080;
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
		defeatText.y = HEIGHT/2 - 350;
		defeatText.text = "Victory!";
		defeatText.textAlign = Center;

        forNowText = new Text(hxd.res.DefaultFont.get(), this);
        forNowText.scale(5);
		forNowText.x = WIDTH/2;
		forNowText.y = HEIGHT/2 - 250;
        // Unit with most re-resurrections: $loses';
		forNowText.textAlign = Center;
        forNowText.alpha = 0;

        MessageManager.addListener(this);
    }

    function setStats() {
        var days = Army.singleton.turns;
        var kills = Army.singleton.kills;
        var losses = Army.singleton.losses;
        var resurrections = Army.singleton.resurrections;
        var defeats = Army.singleton.defeats;
        var path = Army.singleton.longestPath;
        var time = Army.singleton.totalTime;
        forNowText.text = 'Time Taken: $time\nJournies Taken: $days\nLongest Path Travelled: $path\nDefeats: $defeats\nKills: $kills\nLosses: $losses\nResurrections: $resurrections';
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, Victory)) {
            setStats();
            TweenManager.singleton.add(new FadeInTween(this, 0, 5));
            TweenManager.singleton.add(new FadeInTween(forNowText, -3, 2));
        }
        return false;
    }
}
package gamelogic;

import utilities.RNGManager;
import gamelogic.Location;
import h2d.Graphics;
import h2d.Object;
import h2d.Bitmap;
import utilities.Vector2D;
import utilities.MessageManager;

class Castle extends Location {
 
    public function new(p: Object, pos: Vector2D, i: Int, n: Array<Int>, m: Map) {
        super(p, i, n, m);
        position = pos;
        graphics.x = pos.x;
        graphics.y = pos.y;
        new Bitmap(hxd.Res.img.castle.toTile().center(), graphics);

        for (_ in 0...RNGManager.rand.random(10)+20) {
            spawnKnight();
        }
    }

    function spawnKnight() {
        enemies.push(new Knight(graphics.parent, this));
    }

    public override function update(dt: Float) {
        super.update(dt);
        for (p in enemies) p.update(dt);
    }

    public override function receiveMessage(msg:Message):Bool {
        // if (Std.isOfType(msg, TurnComplete)) {
        //     if (enemies.length < 10)
        //         spawnPeasant();
        // }
        return super.receiveMessage(msg);
    }

}
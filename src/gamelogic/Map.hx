package gamelogic;

import h2d.Bitmap;
import h2d.col.Delaunay;
import haxe.ds.Vector;
import hxsl.Types.Vec;
import h2d.col.Bounds;
import h2d.col.Voronoi;
import h2d.col.Point;
import utilities.RNGManager;
import utilities.Vector2D;
import h2d.Graphics;
import h2d.Object;
import utilities.MessageManager;



class Map implements Updateable implements MessageListener {
 
    public var graphics: Graphics;
    public var locations = new Array<Location>();

    final LOCATIONS = 50;
    final WIDTH     = 3000;
    final HEIGHT    = 3000;

    public function receiveMessage(msg:Message):Bool {
		return false;
	}
    
    public function new(p: Object) {
        MessageManager.addListener(this);
        graphics = new Graphics(p);
        var top_left = new Vector2D(0,0);
        var top_right = new Vector2D(0,0);
        var bot_left = new Vector2D(0,0);
        var bot_right = new Vector2D(0,0);
        var points = new Array<Point>();
        points.push(new Vector2D());
        for (_ in 0...LOCATIONS) {
            var unique_location = false;
            var p = new Vector2D();
            while (!unique_location) {
                unique_location = true;
                var x = RNGManager.rand.random(WIDTH) - WIDTH/2;
                var y = RNGManager.rand.random(HEIGHT) - HEIGHT/2;
                p = new Vector2D(x, y);
                for (q in points) {
                    var z :Vector2D = q;
                    if (z.distanceTo(p) < 300) {
                        unique_location = false;
                        break;
                    }
                }
                if (x < top_left.x && y < top_left.y)
                    top_left = new Vector2D(x, y);
                if (x > top_right.x && y < top_right.y)
                    top_right = new Vector2D(x, y);
                if (x < bot_left.x && y > bot_left.y)
                    bot_left = new Vector2D(x, y);
                if (x > bot_right.x && y > bot_right.y)
                    bot_right = new Vector2D(x, y);
            }
            points.push(p);
        }
        var voronoi = new Voronoi();
        var diagram = voronoi.compute(points, Bounds.fromValues(-WIDTH/2,-HEIGHT/2,WIDTH,HEIGHT));

        for (tri in Delaunay.triangulate(points)) {
            if (RNGManager.rand.random(3) == 0)
                continue;
            var p:Vector2D = tri.p1 + tri.p2 + tri.p3;
            p /= 3;
            var bmp: Bitmap = null;
            var i = RNGManager.rand.random(6);
            if (i == 0)
                bmp = new Bitmap(hxd.Res.img.forest1.toTile().center(), graphics);
            if (i == 1)
                bmp = new Bitmap(hxd.Res.img.forest2.toTile().center(), graphics);
            if (i == 2)
                bmp = new Bitmap(hxd.Res.img.forest3.toTile().center(), graphics);
            if (i == 3)
                bmp = new Bitmap(hxd.Res.img.forest4.toTile().center(), graphics);
            if (i == 4)
                bmp = new Bitmap(hxd.Res.img.forest5.toTile().center(), graphics);
            if (i == 5)
                bmp = new Bitmap(hxd.Res.img.forest6.toTile().center(), graphics);
            bmp.scale(2);
            bmp.x = p.x;
            bmp.y = p.y;
            if (RNGManager.rand.random(2) == 0)
                bmp.scaleX = -2;
        }

        for (cell in diagram.cells) {
            for (n in cell.getNeighbors()){
                var start = new Vector2D(cell.point.x, cell.point.y);
                var end = new Vector2D(n.x, n.y);
                var road = hxd.Res.img.road.toTile().center();
                var rotation = (start - end).angle() - Math.PI/2;
                var height = (start - end).magnitude;
                var max = Math.floor(height/road.height);
                for (y in 0...max) {
                    var r: Float = y/max;
                    var f = new Bitmap(road, graphics);
                    f.rotation = rotation;
                    f.x = start.x*(1-r) + end.x*r;
                    f.y = start.y*(1-r) + end.y*r;
                }
            }
        }
        for (cell in diagram.cells) {
            var p: Vector2D = cell.point;
            if (p == new Vector2D()) {
                locations.push(new HQTower(graphics, cell.id, cell.getNeighborIndexes(), this));
                continue;
            } if (p == top_left || p == top_right || p == bot_left || p == bot_right) {
                locations.push(new Castle(graphics, p, cell.id, cell.getNeighborIndexes(), this));
                continue;
            }
            var d = p.magnitude;
            if (d > 600 && RNGManager.rand.random(2) == 0)
                locations.push(new Farm(graphics, p, cell.id, cell.getNeighborIndexes(), this));
            else
                locations.push(new Graveyard(graphics, p, cell.id, cell.getNeighborIndexes(), this));
        }
        for (l in locations) l.init();
    }

    public function update(dt: Float) {
        for (l in locations)
            l.update(dt);
    }
}
package gamelogic;

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
            }
            points.push(p);
        }
        var voronoi = new Voronoi();
        var diagram = voronoi.compute(points, Bounds.fromValues(-WIDTH/2,-HEIGHT/2,WIDTH,HEIGHT));

        for (cell in diagram.cells) {
            for (n in cell.getNeighbors()){
                graphics.lineStyle(10, 0xAAAAAA, 0.25);
                graphics.moveTo(cell.point.x, cell.point.y);
                graphics.lineTo(n.x, n.y);
            }
            var p: Vector2D = cell.point;
            if (p == new Vector2D()) {
                locations.push(new HQTower(graphics, cell.id, cell.getNeighborIndexes(), this));
                continue;
            }
            var d = p.magnitude;
            if (d > 600 && RNGManager.rand.random(2) == 0)
                locations.push(new Farm(graphics, p, cell.id, cell.getNeighborIndexes(), this));
            else
                locations.push(new Graveyard(graphics, p, cell.id, cell.getNeighborIndexes(), this));
        }
    }

    public function update(dt: Float) {
        for (l in locations)
            l.update(dt);
    }
}
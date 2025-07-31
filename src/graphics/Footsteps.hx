package graphics;

import h2d.Bitmap;
import utilities.Vector2D;
import h2d.Object;
import h2d.Graphics;

class Footsteps extends Graphics {
    
    
    public function new(p: Object, start: Vector2D, end: Vector2D) {
        super(p);
        var feet = hxd.Res.img.footsteps.toTile().center();
        trace(start, end);
        var rotation = (start - end).angle() - Math.PI/2;
        var height = (start - end).magnitude;
        var max = Math.floor(height/feet.height);
        trace(max);
        for (y in 0...max) {
            var r: Float = y/max;
            var f = new Bitmap(feet, this);
            f.rotation = rotation;
            f.x = start.x*(1-r) + end.x*r;
            f.y = start.y*(1-r) + end.y*r;
            trace(r);
        }
    }
}
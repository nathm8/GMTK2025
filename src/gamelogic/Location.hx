package gamelogic;

import gamelogic.Corpse;
import h2d.Bitmap;
import utilities.RNGManager;
import utilities.Vector2D;
import h2d.Graphics;
import h2d.Object;
import utilities.MessageManager;

class Location implements Updateable implements MessageListener {
    public static var hqID = 0;
    public var id: Int;
    public var position: Vector2D;
    public var highlight: Graphics;
    public var roads: Graphics;
    public var targetSelected: Bitmap;
    public var selected = false;
    public var highlightRoads(get,set): Bool;
    public var graphics: Graphics;

    public var corpses = new Array<Corpse>();

    public var neighbours = new Array<Location>();
    public var neighbourIndices = new Array<Int>();
    var map: Map;

    public function new(p: Object, i: Int, ns: Array<Int>, m: Map) {
        id = i;
        neighbourIndices = ns;
        map = m;
        graphics = new Graphics(p);
        highlight = new Graphics(graphics);
        new Bitmap(hxd.Res.img.blur.toTile().center(), highlight);
        targetSelected = new Bitmap(hxd.Res.img.targetselected.toTile().center(), highlight);
        targetSelected.visible = false;
        highlight.visible = false;
        MessageManager.addListener(this);
        roads = new Graphics(graphics);
        roads.visible = false;
    }
    public function init() {
        roads.x = -position.x;
        roads.y = -position.y;
        for (n in neighbourIndices)
            neighbours.push(map.locations[n]);
    }

    function isNeighbour(n: Location) : Bool {
        return neighbours.contains(n);
    }

    public function receiveMessage(msg:Message):Bool {
        if (Army.singleton == null) return false;
        if (Army.singleton.state == Marching || Army.singleton.state == AwaitingPickup) return false;
        if (Army.singleton.state == Idle && id != hqID) return false;
        if (Std.isOfType(msg, MouseMove)) {
            var params = cast(msg, MouseMove);
            if ((!isNeighbour(Army.singleton.route[Army.singleton.route.length-1]) || Army.singleton.rangeLeft == 0) 
                && !(Army.singleton.state == Idle && id == hqID))
                return false;
            if (position.distanceTo(params.worldPosition) < 100)
                highlight.visible = true || selected;
            else
                highlight.visible = false || selected;
        }
        if (Std.isOfType(msg, MouseRelease)) {
            var params = cast(msg, MouseRelease);
            if (position.distanceTo(params.worldPosition) < 100) {
                if (selected) {
                    selected = false;
                    highlight.visible = false;
                    targetSelected.visible = false;
                    highlight.rotation = 0;
                    MessageManager.sendMessage(new LocationDeselected(this));
                } else if (isNeighbour(Army.singleton.route[Army.singleton.route.length-1]) && Army.singleton.rangeLeft > 0 || (Army.singleton.state == Idle && id == hqID)){
                    selected = true;
                    highlight.visible = true;
                    highlight.rotation = Math.PI/4;
                    // targetSelected.visible = true;
                    if (id == hqID && Army.singleton.state == Idle) {
                        selected = false;
                        highlight.visible = false;
                    }
                    MessageManager.sendMessage(new LocationSelected(this));
                }
            }
        }
        if (Std.isOfType(msg, March)) {
            selected = false;
            highlight.visible = false;
            targetSelected.visible = false;
            highlightRoads = false;
        }
        return false;
    }

    public function generateCorpse(p: Object, pos: Vector2D = null, t: CorpseType = null, rc: Int = 0) {
        if (pos == null)
            pos = position + new Vector2D(RNGManager.rand.random(200)-100, RNGManager.rand.random(200)-100);
        // Graveyards spawn skelies sometimes
        if (RNGManager.rand.random(4) == 0)
            t = SkeletonCorpse;
        else
            t = ZombieCorpse;
        corpses.push(new Corpse(highlight.parent.parent, pos, t, rc));
    }

	public function update(dt:Float) {
        for (c in corpses) c.update(dt);
    }

    function set_highlightRoads(value:Bool):Bool {
        roads.visible = value;
        if (value == false) return false;
        roads.clear();
        for (n in neighbours) {
            if (Army.canReturnHomeFrom(Army.singleton.rangeLeft-1, Army.singleton.route, n)) {
                roads.lineStyle(10, 0x22AA22, 0.5);
                roads.moveTo(position.x, position.y);
                roads.lineTo(n.position.x, n.position.y);
            } else {
                roads.lineStyle(10, 0xAA2222, 0.5);
                roads.moveTo(position.x, position.y);
                roads.lineTo(n.position.x, n.position.y);
            }
        }
        return true;
    }

	function get_highlightRoads():Bool {
		return roads.visible;
	}
}
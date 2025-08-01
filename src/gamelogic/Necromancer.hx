package gamelogic;

import graphics.TweenManager;
import utilities.RNGManager;
import box2D.dynamics.joints.B2MouseJointDef;
import gamelogic.Unit.DestinationDirectable;
import gamelogic.physics.CircularPhysicalGameObject;
import box2D.dynamics.joints.B2MouseJoint;
import gamelogic.physics.PhysicalWorld;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2BodyType;
import gamelogic.physics.PhysicalWorld.PHYSICSCALEINVERT;
import box2D.dynamics.B2BodyDef;
import box2D.collision.shapes.B2CircleShape;
import h2d.Graphics;
import h2d.Object;
import h2d.Bitmap;
import utilities.Vector2D;
import utilities.MessageManager;

class Necromancer extends Unit implements MessageListener implements DestinationDirectable {
 
    public var graphics: Graphics;
    var mouseJoint: B2MouseJoint;
    var timeFetching = 0.0;

    public function new(p: Object) {
        super();
        MessageManager.addListener(this);
        graphics = new Graphics(p);
        destination = new Vector2D();
        state = Idle;
        new Bitmap(hxd.Res.img.necro.toTile().center(), graphics);

        var body_definition = new B2BodyDef();
        body_definition.type = B2BodyType.DYNAMIC_BODY;
        var circle = new B2CircleShape(20*PHYSICSCALEINVERT);
        var fixture_definition = new B2FixtureDef();
        fixture_definition.shape = circle;
        fixture_definition.userData = this;
        body = PhysicalWorld.gameWorld.createBody(body_definition);
        body.createFixture(fixture_definition);

        var mouse_joint_definition = new B2MouseJointDef();
        mouse_joint_definition.bodyA = new CircularPhysicalGameObject(new Vector2D(), PHYSICSCALEINVERT, 0).body;
        mouse_joint_definition.bodyB = body;
        mouse_joint_definition.collideConnected = false;
        mouse_joint_definition.target = destination;
        mouse_joint_definition.maxForce = 5000;
        mouse_joint_definition.dampingRatio = 1;
        mouse_joint_definition.frequencyHz = 1;
        
        mouseJoint = cast(PhysicalWorld.gameWorld.createJoint(mouse_joint_definition), B2MouseJoint);
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, MouseMove)) {
            if (state == Idle) {
                var params = cast(msg, MouseMove);
                destination = params.worldPosition.normalize()*(RNGManager.rand.random(50)+50);
                destination *= PHYSICSCALEINVERT;
            }
        }
        if (Std.isOfType(msg, March)) {
            state = Moving;
            var start = Army.singleton.route[0].position;
            var end = Army.singleton.route[1].position;
            var dist = (start - end).magnitude;
            var jumps = Math.ceil(dist/80);
            var time = dist/125;
            // trace(start,end);
            // trace(dist, time, jumps);
            var delay = 0.0;
            for (i in 0...jumps) {
                var r:Float = i/jumps;
                var rr = (i+1)/jumps;
                // trace("r", r, rr);
                // trace("start", start*(1-r)+end*r);
                // trace("end", start*(1-r+1/jumps)+end*(r+1/jumps));
                // trace("delay", delay);
                // trace("timetotal", time/jumps);
                TweenManager.singleton.add(new PhysicalMoveBounceTween(this, start*(1-r)+end*r, start*(1-rr)+end*(rr), -delay, time/jumps));
                delay += time/jumps;
            }
            TweenManager.singleton.add(new DelayedCallTween(() -> Army.singleton.progress(), -delay, 3));
        }
        return false;
    }
    
    public override function update(dt: Float) {
        super.update(dt);
        graphics.x = body.getPosition().x*PHYSICSCALE;
        graphics.y = body.getPosition().y*PHYSICSCALE;
        if (state == FetchingCorpse) {
            var cp: Vector2D = body.getPosition();
            cp -= corpse.body.getPosition();
            destination = corpse.body.getPosition() - cp.normalize()*0.5;
            timeFetching += dt;
            if (timeFetching > 1) {
                corpse.attachToBody(body);
                MessageManager.sendMessage(new CorpsePickup());
                state = Moving;
            }
        } else 
            timeFetching = 0;
        mouseJoint.setTarget(destination);
    }
}
package gamelogic;

import graphics.TweenManager;
import utilities.RNGManager;
import box2D.dynamics.joints.B2MouseJointDef;
import gamelogic.physics.CircularPhysicalGameObject;
import box2D.dynamics.joints.B2MouseJoint;
import gamelogic.physics.PhysicalWorld;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2BodyType;
import gamelogic.physics.PhysicalWorld.PHYSICSCALEINVERT;
import box2D.dynamics.B2BodyDef;
import box2D.collision.shapes.B2CircleShape;
import box2D.dynamics.B2Body;
import h2d.Graphics;
import h2d.Object;
import h2d.Bitmap;
import utilities.Vector2D;
import utilities.MessageManager;

enum NecromancerState {
    Idle;
    Moving;
}

interface DestinationDirectable {
    public var destination: Vector2D;
}

class Necromancer implements Updateable implements MessageListener implements DestinationDirectable {
 
    public var graphics: Graphics;
    public var state: NecromancerState;
    var body: B2Body;
    var mouseJoint: B2MouseJoint;
	public var destination:Vector2D;

    public function new(p: Object) {
        MessageManager.addListener(this);
        graphics = new Graphics(p);
        destination = new Vector2D();
        state = Idle;
        new Bitmap(hxd.Res.img.necro.toTile().center(), graphics);

        var body_definition = new B2BodyDef();
        body_definition.type = B2BodyType.DYNAMIC_BODY;
        var circle = new B2CircleShape(10*PHYSICSCALEINVERT);
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
        mouse_joint_definition.maxForce = 1000;
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
            var time = dist/80;
            trace(dist, time, jumps);
            var delay = 0.0;
            for (i in 0...jumps) {
                var r:Float = i/jumps;
                TweenManager.singleton.add(new PhysicalMoveBounceTween(this, start*(1-r)+end*r, start*(1-r+1/jumps)+end*(r+1/jumps), -delay, time/jumps));
                delay += time/jumps;
            }
        }
        return false;
    }
    
    public function update(dt: Float) {
        graphics.x = body.getPosition().x*PHYSICSCALE;
        graphics.y = body.getPosition().y*PHYSICSCALE;
        mouseJoint.setTarget(destination);
    }
}
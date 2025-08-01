package gamelogic;

import box2D.dynamics.B2Body;
import gamelogic.Necromancer.DestinationDirectable;
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
import h2d.Graphics;
import h2d.Object;
import h2d.Bitmap;
import utilities.Vector2D;
import utilities.MessageManager;

class Skeleton extends Unit implements MessageListener implements DestinationDirectable {
 
    public var graphics: Graphics;
    var mouseJoint: B2MouseJoint;
    var necromancer: Necromancer;
	public var destination:Vector2D;
    var totalTime = 0.0;

    public function new(p: Object, n: Necromancer, b: B2Body) {
        super();
        MessageManager.addListener(this);
        graphics = new Graphics(p);
        destination = new Vector2D();
        necromancer = n;
        new Bitmap(hxd.Res.img.skelly.toTile().center(), graphics);

        body = b;
        body.getFixtureList().setDensity(0.75);
        body.getFixtureList().setUserData(this);

        var mouse_joint_definition = new B2MouseJointDef();
        mouse_joint_definition.bodyA = new CircularPhysicalGameObject(new Vector2D(), PHYSICSCALEINVERT, 0).body;
        mouse_joint_definition.bodyB = body;
        mouse_joint_definition.collideConnected = false;
        mouse_joint_definition.target = destination;
        mouse_joint_definition.maxForce = 0.5;
        mouse_joint_definition.dampingRatio = 0.75;
        mouse_joint_definition.frequencyHz = 0.5;
        
        mouseJoint = cast(PhysicalWorld.gameWorld.createJoint(mouse_joint_definition), B2MouseJoint);
    }

    public function receiveMessage(msg:Message):Bool {
        return false;
    }
    
    public override function update(dt: Float) {
        graphics.x = body.getPosition().x*PHYSICSCALE;
        graphics.y = body.getPosition().y*PHYSICSCALE;

        totalTime += dt*RNGManager.rand.rand();
        if (totalTime > 0.05) {
            totalTime = 0;
            var d = necromancer.body.getPosition();
            d.x += (RNGManager.rand.rand()-0.5)/12;
            d.y += (RNGManager.rand.rand()-0.5)/12;
            mouseJoint.setTarget(d);
        }
    }
}
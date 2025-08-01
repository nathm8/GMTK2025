package gamelogic;

import gamelogic.Location;
import box2D.dynamics.B2Body;
import gamelogic.Unit.DestinationDirectable;
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

enum EnemyState {
    Idle;
    Attacking;
}

class Peasant implements Updateable implements MessageListener implements DestinationDirectable {
 
    public var graphics: Graphics;
    var mouseJoint: B2MouseJoint;
	public var destination:Vector2D;
    var body: B2Body;
    var state = Idle;
    var totalTime = 0.0;
    var location: Location;

    public function new(p: Object, l: Location) {
        totalTime = RNGManager.rand.rand();
        location = l;
        MessageManager.addListener(this);
        graphics = new Graphics(p);
        new Bitmap(hxd.Res.img.peasant.toTile().center(), graphics);
        
        var body_definition = new B2BodyDef();
        body_definition.type = B2BodyType.DYNAMIC_BODY;
        body_definition.position = l.position*PHYSICSCALEINVERT;
        body_definition.position += new Vector2D(RNGManager.rand.random(100)-50, RNGManager.rand.random(100)-50)*PHYSICSCALEINVERT;
        destination = body_definition.position;
        var circle = new B2CircleShape(10*PHYSICSCALEINVERT);
        var fixture_definition = new B2FixtureDef();
        fixture_definition.shape = circle;
        fixture_definition.userData = this;
        fixture_definition.density = 0.25;
        body = PhysicalWorld.gameWorld.createBody(body_definition);
        body.createFixture(fixture_definition);

        var mouse_joint_definition = new B2MouseJointDef();
        mouse_joint_definition.bodyA = new CircularPhysicalGameObject(new Vector2D(), PHYSICSCALEINVERT, 0).body;
        mouse_joint_definition.bodyB = body;
        mouse_joint_definition.collideConnected = false;
        mouse_joint_definition.target = destination;
        mouse_joint_definition.maxForce = 0.3;
        mouse_joint_definition.dampingRatio = 1;
        mouse_joint_definition.frequencyHz = 0.1;
        
        mouseJoint = cast(PhysicalWorld.gameWorld.createJoint(mouse_joint_definition), B2MouseJoint);
    }

    public function receiveMessage(msg:Message):Bool {
        return false;
    }
    
    public function update(dt: Float) {
        graphics.x = body.getPosition().x*PHYSICSCALE;
        graphics.y = body.getPosition().y*PHYSICSCALE;

        if (state == Idle) {
            totalTime += dt;
            if (totalTime > 1) {
                totalTime = 0;
                destination = location.position*PHYSICSCALEINVERT;
                destination += new Vector2D(RNGManager.rand.random(150)-75, RNGManager.rand.random(150)-75)*PHYSICSCALEINVERT;
                mouseJoint.setTarget(destination);
            }
        }
    }
}
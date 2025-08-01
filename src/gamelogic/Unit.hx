package gamelogic;

import h3d.Vector4;
import graphics.TweenManager;
import box2D.dynamics.joints.B2DistanceJointDef;
import gamelogic.physics.PhysicalWorld;
import gamelogic.physics.PhysicalWorld.PHYSICSCALEINVERT;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2CircleShape;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2BodyDef;
import h2d.Bitmap;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
import h2d.Object;
import box2D.dynamics.joints.B2DistanceJoint;
import box2D.dynamics.B2Body;
import h2d.Graphics;

enum CorpseType {
    ZombieCorpse;
    SkeletonCorpse;
}

class Corpse implements Updateable {

    public var graphics: Graphics;
    public var body: B2Body;
    // var distanceJoint: B2DistanceJoint;

    public function new(p: Object, b: B2Body) {
        graphics = new Graphics(p);
        new Bitmap(hxd.Res.img.zombie.toTile().center(), graphics);
        var mask = new Bitmap(hxd.Res.img.unitmask.toTile().center(), graphics);
        mask.alpha = 0.75;
        graphics.rotation = Math.PI/2;
        graphics.alpha = 0;

        TweenManager.singleton.add(new RaiseTween(graphics, 20, 0, 0, 2));
        TweenManager.singleton.add(new FadeInTween(graphics, 0, 2));

        var body_definition = new B2BodyDef();
        body_definition.type = B2BodyType.DYNAMIC_BODY;
        var circle = new B2CircleShape(10*PHYSICSCALEINVERT);
        var fixture_definition = new B2FixtureDef();
        fixture_definition.shape = circle;
        fixture_definition.userData = this;
        body = PhysicalWorld.gameWorld.createBody(body_definition);
        body.createFixture(fixture_definition);

        var distance_joint_definition = new B2DistanceJointDef();
        distance_joint_definition.bodyA = b;
        distance_joint_definition.bodyB = body;
        distance_joint_definition.length = PHYSICSCALEINVERT*2;
        distance_joint_definition.collideConnected = true;
        distance_joint_definition.dampingRatio = 0.5;
        distance_joint_definition.frequencyHz = 1;   
        PhysicalWorld.gameWorld.createJoint(distance_joint_definition);
    }

    public function update(dt:Float) {
        graphics.x = body.getPosition().x*PHYSICSCALE;
        graphics.y = body.getPosition().y*PHYSICSCALE;
    }
}

class Unit implements MessageListener {
    public var corpse: Corpse;

    public function receiveMessage(msg:Message):Bool {
        return false;
    }
}
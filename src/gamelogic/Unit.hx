package gamelogic;

import box2D.dynamics.joints.B2Joint;
import utilities.MessageManager;
import graphics.TweenManager;
import box2D.dynamics.joints.B2DistanceJointDef;
import gamelogic.physics.PhysicalWorld;
import gamelogic.physics.PhysicalWorld.PHYSICSCALEINVERT;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2CircleShape;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2BodyDef;
import h2d.Bitmap;
import utilities.MessageManager.CorpseDestroyed;
import h2d.Object;
import box2D.dynamics.B2Body;
import h2d.Graphics;

enum CorpseType {
    ZombieCorpse;
    SkeletonCorpse;
}

class Corpse implements Updateable {

    public var graphics: Graphics;
    public var body: B2Body;
    public var type: CorpseType;
    var sprite: Bitmap;
    var mask: Bitmap;
    var joint: B2Joint;
    // var distanceJoint: B2DistanceJoint;

    public function new(p: Object, b: B2Body, t: CorpseType) {
        graphics = new Graphics(p);
        if (t == ZombieCorpse)
            sprite = new Bitmap(hxd.Res.img.zombie.toTile().center(), graphics);
        else if (t == SkeletonCorpse)
            sprite = new Bitmap(hxd.Res.img.skelly.toTile().center(), graphics);
        type = t;
        mask = new Bitmap(hxd.Res.img.unitmask.toTile().center(), sprite);
        mask.alpha = 0.75;
        sprite.rotation = Math.PI/2;
        graphics.alpha = 0;

        TweenManager.singleton.add(new RaiseTween(sprite, 20, 0, 0, 2));
        TweenManager.singleton.add(new FadeInTween(graphics, 0, 2));

        graphics.x = b.getPosition().x*PHYSICSCALE;
        graphics.y = b.getPosition().y*PHYSICSCALE;
        graphics.y += 15;

        var body_definition = new B2BodyDef();
        body_definition.type = B2BodyType.DYNAMIC_BODY;
        body_definition.position = b.getPosition();
        body_definition.position.y += 15*PHYSICSCALEINVERT;
        var circle = new B2CircleShape(10*PHYSICSCALEINVERT);
        var fixture_definition = new B2FixtureDef();
        fixture_definition.shape = circle;
        fixture_definition.userData = this;
        fixture_definition.density = 0.00001;
        body = PhysicalWorld.gameWorld.createBody(body_definition);
        body.createFixture(fixture_definition);

        var distance_joint_definition = new B2DistanceJointDef();
        distance_joint_definition.bodyA = b;
        distance_joint_definition.bodyB = body;
        distance_joint_definition.length = PHYSICSCALEINVERT*21;
        distance_joint_definition.collideConnected = false;
        joint = PhysicalWorld.gameWorld.createJoint(distance_joint_definition);
    }

    public function update(dt:Float) {
        graphics.x = body.getPosition().x*PHYSICSCALE;
        graphics.y = body.getPosition().y*PHYSICSCALE;
    }

    public function resurrect() {
        TweenManager.singleton.add(new FadeOutTween(mask, 0, 2));
        TweenManager.singleton.add(new ScaleBounceTween(sprite, 0, 3));
        TweenManager.singleton.add(new RotateTween(sprite, Math.PI/2, 0, 0, 1));
        TweenManager.singleton.add(new DelayedCallTween(() -> MessageManager.sendMessage(new NewUnit(this)), -3, 0));
        TweenManager.singleton.add(new DelayedCallTween(destroy, -3, 0));
    }

    function destroy() {
        MessageManager.sendMessage(new CorpseDestroyed(this));
        PhysicalWorld.gameWorld.destroyJoint(joint);
        graphics.remove();
    }
}

class Unit implements Updateable {
    public var corpse: Corpse;
    public var body: B2Body;
    public var id: Int;
    static var maxID = 0;

    public function new() {
        id = maxID++;    
    }

    public function update(dt:Float) {}
}
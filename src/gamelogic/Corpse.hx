package gamelogic;

import box2D.dynamics.joints.B2DistanceJoint;
import utilities.Vector2D;
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
    PeasantCorpse;
}

class Corpse implements Updateable {

    public var graphics: Graphics;
    public var body: B2Body;
    public var type: CorpseType;
    var sprite: Bitmap;
    var mask: Bitmap;
    public var joint: B2Joint;
    var resurrectionCount = 0;
    var resurrecting = false;
    // var distanceJoint: B2DistanceJoint;

    public function new(p: Object, pos: Vector2D, t: CorpseType, b:B2Body, rez_count=0) {
        // TODO, size and power increase
        resurrectionCount = rez_count;
        graphics = new Graphics(p);
        if (t == ZombieCorpse)
            sprite = new Bitmap(hxd.Res.img.zombie.toTile().center(), graphics);
        else if (t == SkeletonCorpse)
            sprite = new Bitmap(hxd.Res.img.skelly.toTile().center(), graphics);
        else if (t == PeasantCorpse)
            sprite = new Bitmap(hxd.Res.img.peasantzomb.toTile().center(), graphics);
        if (t == ZombieCorpse || t == SkeletonCorpse)
            mask = new Bitmap(hxd.Res.img.unitmask.toTile().center(), sprite);
        else
            mask = new Bitmap(hxd.Res.img.peasantmask.toTile().center(), sprite);
        type = t;
        mask.alpha = 0.75;
        sprite.rotation = Math.PI/2;
        graphics.alpha = 0;

        // TweenManager.singleton.add(new RaiseTween(sprite, 20, 0, 0, 2));
        TweenManager.singleton.add(new FadeInTween(graphics, 0, 0.5));

        if (b == null) {
            var body_definition = new B2BodyDef();
            body_definition.type = B2BodyType.DYNAMIC_BODY;
            body_definition.position = pos*PHYSICSCALEINVERT;
            body_definition.linearDamping = 1;
            var circle = new B2CircleShape(10*PHYSICSCALEINVERT);
            var fixture_definition = new B2FixtureDef();
            fixture_definition.shape = circle;
            fixture_definition.userData = this;
            fixture_definition.density = 50000;
            body = PhysicalWorld.gameWorld.createBody(body_definition);
            body.createFixture(fixture_definition);
        } else {
            body = b;
            body.getFixtureList().setDensity(50000);
            body.resetMassData();
            body.getFixtureList().setUserData(this);
            body.setLinearDamping(1.0);
        }

        graphics.x = body.getPosition().x*PHYSICSCALE;
        graphics.y = body.getPosition().y*PHYSICSCALE;
    }
    
    public function detach() {
        if (joint != null) {
            body.getFixtureList().setDensity(50000);
            body.resetMassData();
            PhysicalWorld.gameWorld.destroyJoint(joint);
        }
    }

    public function attachToBody(b: B2Body) {
        detach();
        body.getFixtureList().setDensity(0.001);
        body.resetMassData();
        var d: Vector2D = b.getPosition();
        d -= body.getPosition();
        var distance_joint_definition = new B2DistanceJointDef();
        distance_joint_definition.bodyA = b;
        distance_joint_definition.bodyB = body;
        distance_joint_definition.length = d.magnitude*1.01;
        distance_joint_definition.collideConnected = false;
        joint = PhysicalWorld.gameWorld.createJoint(distance_joint_definition);
    }

    public function update(dt:Float) {
        graphics.x = body.getPosition().x*PHYSICSCALE;
        graphics.y = body.getPosition().y*PHYSICSCALE;
        if (joint != null) {
            var dist = cast(joint, B2DistanceJoint);
            if (dist.getLength() > 1) {
                dist.setLength(dist.getLength() - 10*dt);
            }
        }
    }

    public function resurrect() {
        detach();
        resurrecting = true;
        TweenManager.singleton.add(new FadeOutTween(mask, 0, 2));
        TweenManager.singleton.add(new ScaleBounceTween(sprite, 0, 3));
        TweenManager.singleton.add(new RotateTween(sprite, Math.PI/2, 0, 0, 1));
        TweenManager.singleton.add(new DelayedCallTween(() -> MessageManager.sendMessage(new NewUnit(this)), -3, 0));
        TweenManager.singleton.add(new DelayedCallTween(destroy, -3, 0));
        TweenManager.singleton.add(new DelayedCallTween(() -> resurrecting = false, -3, 0));
    }

    public function destroy() {
        detach();
        graphics.remove();
        MessageManager.sendMessage(new CorpseDestroyed(this));
    }
}
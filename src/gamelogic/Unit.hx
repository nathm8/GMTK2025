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
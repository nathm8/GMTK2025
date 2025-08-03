package gamelogic;

import box2D.dynamics.B2Body;
import gamelogic.Unit.DestinationDirectable;
import utilities.RNGManager;
import box2D.dynamics.joints.B2MouseJointDef;
import gamelogic.physics.CircularPhysicalGameObject;
import box2D.dynamics.joints.B2MouseJoint;
import gamelogic.physics.PhysicalWorld;
import gamelogic.physics.PhysicalWorld.PHYSICSCALEINVERT;
import h2d.Graphics;
import h2d.Object;
import h2d.Bitmap;
import utilities.Vector2D;
import utilities.MessageManager;

class Zombie extends Unit implements MessageListener implements DestinationDirectable {
 
    public var graphics: Graphics;
    var mouseJoint: B2MouseJoint;
    var necromancer: Necromancer;
    var hitpointIndicator: Bitmap;
    var necromancerPositions = new Array<Vector2D>();
    var totalTime = 0.0;
    var timeExecuting = 0.0;

    public function new(p: Object, n: Necromancer, b: B2Body, isPeasant=false) {
        super();
        hitpoints = 1.0;
        corpseType = ZombieCorpse;
        MessageManager.addListener(this);
        graphics = new Graphics(p);
        destination = new Vector2D();
        necromancer = n;
        if  (!isPeasant) {
            new Bitmap(hxd.Res.img.zombie.toTile().center(), graphics);
            hitpointIndicator = new Bitmap(hxd.Res.img.unitmask.toTile().center(), graphics);
        }
        else {
            new Bitmap(hxd.Res.img.peasantzomb.toTile().center(), graphics);
            hitpointIndicator = new Bitmap(hxd.Res.img.peasantmask.toTile().center(), graphics);
        }
        hitpointIndicator.alpha = 0;

        body = b;
        body.getFixtureList().setDensity(0.5);
        body.resetMassData();
        body.getFixtureList().setUserData(this);
        body.setLinearDamping(0.5);

        var mouse_joint_definition = new B2MouseJointDef();
        mouse_joint_definition.bodyA = new CircularPhysicalGameObject(new Vector2D(), PHYSICSCALEINVERT, 0).body;
        mouse_joint_definition.bodyB = body;
        mouse_joint_definition.collideConnected = false;
        mouse_joint_definition.target = body.getPosition();
        mouse_joint_definition.maxForce = 1;
        mouse_joint_definition.dampingRatio = 1;
        mouse_joint_definition.frequencyHz = 0.25;
        
        mouseJoint = cast(PhysicalWorld.gameWorld.createJoint(mouse_joint_definition), B2MouseJoint);

        for (_ in 0...3)
            necromancerPositions.unshift(necromancer.body.getPosition());
    }

    public function receiveMessage(msg:Message):Bool {
        return false;
    }
    
    public override function update(dt: Float) {
        super.update(dt);
        graphics.x = body.getPosition().x*PHYSICSCALE;
        graphics.y = body.getPosition().y*PHYSICSCALE;
        hitpointIndicator.alpha = 1 - (hitpoints / 1.0);
        hitpointIndicator.alpha < .1 ? hitpointIndicator.alpha = .1 : null;
        if (state == Dead) return;

        if (state == Idle) {
            totalTime += dt*RNGManager.rand.rand();
            if (totalTime > 0.05) {
                totalTime = 0;
                totalTime = -RNGManager.rand.rand()*0.05;
                necromancerPositions.unshift(necromancer.body.getPosition());
                var d = necromancerPositions.pop();
                d.x += (RNGManager.rand.rand()-0.5)/4;
                d.y += (RNGManager.rand.rand()-0.5)/4;
                destination = d;
            }
        } if (state == FetchingCorpse) {
            var cp: Vector2D = body.getPosition();
            cp -= corpse.body.getPosition();
            if (corpse != null)
                destination = corpse.body.getPosition() - cp.normalize()*0.1;
            timeExecuting += dt;
            if (timeExecuting > 3) {
                corpse.attachToBody(body);
                MessageManager.sendMessage(new CorpsePickup());
                state = Idle;
            }
        } else if (state == Attacking) {
            timeExecuting += dt;
            var v: Vector2D = body.getPosition();
            v -= target.body.getPosition();
            var r = new Vector2D(RNGManager.rand.rand()-0.5, RNGManager.rand.rand()-0.5) * 0.1;
            destination = target.body.getPosition() - v.normalize()*0.1 + r;
            if (timeExecuting > 5) {
                trace("zomb taking too long, magic attack");
                target.hitpoints -= 0.01;
                hitpoints -= 0.01;
            }
        } else 
            timeExecuting = 0;
        mouseJoint.setTarget(destination);
    }

    public override function attack(c: Combatant) {
        super.attack(c);
        timeExecuting = 0;
    }

    public function destroy() {
        graphics.remove();
        PhysicalWorld.gameWorld.destroyJoint(mouseJoint);
        if (corpse != null) {
            corpse.detach();
            Army.singleton.route[0].corpses.push(corpse);
        }
        corpse = null;
    }
}
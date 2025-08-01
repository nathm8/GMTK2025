package gamelogic.physics;

import utilities.Vector2D;
import utilities.MessageManager;
import box2D.dynamics.B2ContactImpulse;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.B2ContactListener;

class ContactListener extends B2ContactListener {
    override public function postSolve(contact:B2Contact, impulse:B2ContactImpulse):Void {
        var object_a = contact.getFixtureA().getUserData();
        var object_b = contact.getFixtureB().getUserData();
        // units picking up corpses should change their state
        function pickUpCheck(uda: Dynamic, udb: Dynamic) {
            if (Std.isOfType(uda, Unit)) {
                var u = cast(uda, Unit);
                if (u.state == FetchingCorpse) {
                    if (Std.isOfType(udb, Corpse)) {
                        var c = cast(udb, Corpse);
                        if (u.corpse == c) {
                            var v:Vector2D = u.body.getPosition();
                            c.attachToBody(u.body);
                            MessageManager.sendMessage(new CorpsePickup());
                            u.state = Idle;
                            // ugly hack, bad OOP, bad programmer
                            if (Std.isOfType(u, Necromancer))
                                u.state = Moving;
                        }
                    }
                }
            }
        }
        // idk if this is actually necessary but gotta go fast, explore with box2d later
        pickUpCheck(object_a, object_b);
        pickUpCheck(object_b, object_a);
    }
}
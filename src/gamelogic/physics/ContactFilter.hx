package gamelogic.physics;

import utilities.MessageManager;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2ContactFilter;

class ContactFilter extends B2ContactFilter {
    override function shouldCollide(fixtureA:B2Fixture, fixtureB:B2Fixture):Bool {
        var user_data_a = fixtureA.getUserData();       
        var user_data_b = fixtureB.getUserData();
        // have some zombies not collide, for performance
        if (Std.isOfType(user_data_a, Zombie) && Std.isOfType(user_data_b, Zombie)) {
            var id_a = cast(user_data_a, Zombie).id;
            var id_b = cast(user_data_a, Zombie).id;
            if ((id_a % 2 == 0 && id_b % 2 == 0) || (id_a % 1 == 0 && id_b % 1 == 0))
                return false;
        }
        // units picking up corpses should change their state
        function pickUpCheck(uda: Dynamic, udb: Dynamic) {
            if (Std.isOfType(uda, Unit)) {
                var u = cast(uda, Unit);
                if (u.state == FetchingCorpse) {
                    if (Std.isOfType(udb, Corpse)) {
                        var c = cast(udb, Corpse);
                        if (u.corpse == c) {
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
        pickUpCheck(user_data_a, user_data_b);
        pickUpCheck(user_data_b, user_data_a);
        // CircularPhysicalGameObjects with default userdata do not collide
        if (Std.isOfType(user_data_a, Int) || Std.isOfType(user_data_b, Int))
            return false;
        // unattached corpses should not collide
        if (Std.isOfType(user_data_a, Corpse)) {
            var c = cast(user_data_a, Corpse);
            if (c.joint == null)
                return false;
        }
        if (Std.isOfType(user_data_b, Corpse)) {
            var c = cast(user_data_b, Corpse);
            if (c.joint == null)
                return false;
        }
        return true;
    }
}
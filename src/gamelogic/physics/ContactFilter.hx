package gamelogic.physics;

import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2ContactFilter;

class ContactFilter extends B2ContactFilter {
    override function shouldCollide(fixtureA:B2Fixture, fixtureB:B2Fixture):Bool {
        var user_data_a = fixtureA.getUserData();       
        var user_data_b = fixtureB.getUserData();
        // have some zombies not collide, for performance
        // if (Std.isOfType(user_data_a, Zombie) && Std.isOfType(user_data_b, Zombie)) {
        //     var id_a = cast(user_data_a, Zombie).id;
        //     var id_b = cast(user_data_a, Zombie).id;
        //     if ((id_a % 2 == 0 && id_b % 2 == 0) || (id_a % 1 == 0 && id_b % 1 == 0))
        //         return false;
        // }
        // CircularPhysicalGameObjects with default userdata do not collide
        if (Std.isOfType(user_data_a, Int) || Std.isOfType(user_data_b, Int))
            return false;

        // unattached corpses should not collide, unless it is their seeker
        function shouldCorpseCollide(uda: Dynamic, udb: Dynamic) : Bool {
            if ((Std.isOfType(udb, Corpse))) {
                var c = cast(udb, Corpse);
                if (Std.isOfType(uda, Unit)) {
                    var u = cast(uda, Unit);
                    return u.corpse == c;
                }
                if (c.joint == null) return false;
            }
            return true;
        }
        // idk if this is actually necessary but gotta go fast, explore with box2d later
        if (!shouldCorpseCollide(user_data_a, user_data_b) || !shouldCorpseCollide(user_data_b, user_data_a))
            return false;

        return true;
    }
}
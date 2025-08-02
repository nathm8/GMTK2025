package gamelogic;

import gamelogic.Corpse.CorpseType;
import utilities.MessageManager;
import utilities.Vector2D;
import box2D.dynamics.B2Body;

enum UnitState {
    Idle;
    FetchingCorpse;
    Moving; // only tracked for the necromancer
    Attacking;
    Dead;
}

interface DestinationDirectable {
    public var destination: Vector2D;
}

abstract class Unit implements Updateable implements DestinationDirectable implements Combatant {
    public var corpse: Corpse;
    public var id: Int;
    static var maxID = 0;
    public var state = Idle;
	public var destination:Vector2D;
	public var hitpoints(default, set):Float;
	public var isUndead:Bool=true;
	public var body:B2Body;
	public var target:B2Body;
	public var resurrectionCount: Int;
	public var corpseType:CorpseType;

    public function new(rc=0) {
        id = maxID++;    
        resurrectionCount = rc;
    }

    public function update(dt:Float) {
        corpse?.update(dt);
    }

    public function fetchCorpse(c: Corpse) {
        state = FetchingCorpse;
        destination = c.body.getPosition();
    }

    function set_hitpoints(value:Float):Float {
        trace("undead damaged");
        if (value <= 0) {
            trace("undead died");
            MessageManager.sendMessage(new UnitDeath(this));
        }
        hitpoints = value;
        return value;
    }

    public function attack(c: Combatant) {
        state = Attacking;
        target = c.body;
        destination = c.body.getPosition();
    }

    abstract public function destroy() : Void;
}
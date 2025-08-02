package gamelogic;

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

class Unit implements Updateable implements DestinationDirectable implements Combatant {
    public var corpse: Corpse;
    public var id: Int;
    static var maxID = 0;
    public var state = Idle;
	public var destination:Vector2D;
	public var hitpoints(default, set):Float;
	public var isUndead:Bool=true;
	public var body:B2Body;
	public var target:B2Body;

    public function new() {
        id = maxID++;    
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
        if (value <= 0)
            MessageManager.sendMessage(new UnitDeath(this));
        hitpoints = value;
        return value;
    }

    public function attack(c: Combatant) {
        state = Attacking;
        target = c.body;
        destination = c.body.getPosition();
    }
}
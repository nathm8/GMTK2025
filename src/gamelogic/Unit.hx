package gamelogic;

import utilities.MessageManager;
import utilities.Vector2D;
import box2D.dynamics.B2Body;

enum UnitState {
    Idle;
    FetchingCorpse;
    Moving; // only tracked for the necromancer
}

interface DestinationDirectable {
    public var destination: Vector2D;
}

class Unit implements Updateable implements DestinationDirectable {
    public var corpse: Corpse;
    public var body: B2Body;
    public var id: Int;
    static var maxID = 0;
    public var state = Idle;
	public var destination:Vector2D;

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
}
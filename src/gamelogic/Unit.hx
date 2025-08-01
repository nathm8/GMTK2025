package gamelogic;

import box2D.dynamics.B2Body;

enum UnitState {
    Idle;
    FetchingCorpse;
    Moving; // only tracked for the necromancer
}

class Unit implements Updateable {
    public var corpse: Corpse;
    public var body: B2Body;
    public var id: Int;
    static var maxID = 0;
    public var state = Idle;

    public function new() {
        id = maxID++;    
    }

    public function update(dt:Float) {}

    public function fetchCorpse(c: Corpse) {
        
    }
}
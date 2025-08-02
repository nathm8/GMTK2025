package gamelogic;

import box2D.dynamics.B2Body;

interface Combatant {
    public var body: B2Body;
    public var target: B2Body;
    public var hitpoints(default, set): Float;   
    public var isUndead: Bool;
    public function attack(c: Combatant): Void;
}
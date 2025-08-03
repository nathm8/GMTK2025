package gamelogic;

import gamelogic.Corpse.CorpseType;
import box2D.dynamics.B2Body;

interface Combatant {
    public var body: B2Body;
    public var target: Combatant;
    public var hitpoints(default, set): Float;   
    public var isUndead: Bool;
    public var resurrectionCount: Int;
    public var corpseType: CorpseType;
    public function attack(c: Combatant): Void;
}
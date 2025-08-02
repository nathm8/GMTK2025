package gamelogic;

import gamelogic.Corpse.CorpseType;
import box2D.dynamics.B2Body;

enum EnemyState {
    Idle;
    Attacking;
    Dead;
}

abstract class Enemy implements Combatant implements Updateable {
    public var state: EnemyState;

    public var id: Int;
    static var maxID = 0;
	public var body:B2Body;
	public var target:Combatant;
	public var hitpoints(default, set):Float;
	public var isUndead = false;
	public var resurrectionCount = 0;
	public var corpseType:CorpseType;

    public function new(rc=0) {
        id = maxID++;    
    }

    function set_hitpoints(value:Float):Float {
        throw new haxe.exceptions.NotImplementedException();
    }
}
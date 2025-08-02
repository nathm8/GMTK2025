package gamelogic;

enum EnemyState {
    Idle;
    Attacking;
    Dead;
}

interface Enemy extends Combatant extends Updateable {
    public var state: EnemyState;
}
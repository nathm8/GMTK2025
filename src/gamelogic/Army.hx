package gamelogic;

import h2d.Graphics;
import utilities.MessageManager;
import h2d.Object;
import gamelogic.Map.Location;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;

enum ArmyState {
    Idle;
    Planning;
    Marching;
}

class Army implements Updateable implements MessageListener {

    var range = 1000;
    var route = new Array<Location>();
    public var graphics: Graphics;
    public var state: ArmyState;

    public function new(p: Object) {
        MessageManager.addListener(this);
        graphics = new Graphics(p);
        state = Idle;
    }

    public function receiveMessage(msg:Message):Bool {
        if (Std.isOfType(msg, MouseReleaseMessage)) {
            if (state != Marching) {
                var params = cast(msg, MouseReleaseMessage);
                
            }
        }
        return false;
    }

    public function update(dt:Float) {}
}
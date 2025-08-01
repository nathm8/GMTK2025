package utilities;

import gamelogic.Unit.Corpse;
import gamelogic.Map.Location;
import hxd.Event;
import utilities.Vector2D;

class Message {public function new(){}}

class PhysicsStepDone extends Message {}
class Restart extends Message {}
class MouseClick extends Message {
	public var event: Event;
	public var worldPosition: Vector2D;
	public function new(e: Event, p: Vector2D) {super(); event = e; worldPosition = p;}
}
class KeyUp extends Message {
	public var keycode: Int;
	public function new(k: Int) {super(); keycode = k;}
}
class MouseRelease extends Message {
	public var event: Event;
	public var worldPosition: Vector2D;
	public function new(e: Event, p: Vector2D) {super(); event = e; worldPosition = p;}
}
class MouseMove extends Message {
	public var event: Event;
	public var worldPosition: Vector2D;
	public function new(e: Event, p: Vector2D) {super(); event = e; worldPosition = p;}
}
class Victory extends Message {
	public var t: Float;
	public var k: Int;
	public function new(t: Float, k: Int) {super(); this.t = t; this.k = k;}
}
class LocationSelected extends Message {
	public var location: Location;
	public function new(k: Location) {super(); location = k;}
}
class March extends Message {
}
class LocationDeselected extends Message {
	public var location: Location;
	public function new(k: Location) {super(); location = k;}
}
class CorpseDestroyed extends Message {
	public var corpse: Corpse;
	public function new(k: Corpse) {super(); corpse = k;}
}
class NewUnit extends Message {
	public var corpse: Corpse;
	public function new(k: Corpse) {super(); corpse = k;}
}

interface MessageListener {
    public function receiveMessage(msg: Message): Bool;
}

class MessageManager {

    static var listeners = new Array<MessageListener>();

	public static function addListener(l:MessageListener) {
		listeners.push(l);
    }

	public static function removeListener(l:MessageListener) {
		listeners.remove(l);
    }

    public static function sendMessage(msg: Message) {
        for (l in listeners)
            if (l.receiveMessage(msg)) return;
		// trace("unconsumed message", msg);
    }

	public static function reset() {
		listeners = [];
	}

}
package events;

import entities.Ship;
import flixel.FlxSprite;

class RenderEvent {
	public var beat:Int;
	public var sprite:Ship;

	public function new(beat:Int, sprite:Ship) {
		this.beat = beat;
		this.sprite = sprite;
	}
}
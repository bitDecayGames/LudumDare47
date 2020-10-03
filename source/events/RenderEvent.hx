package events;

import flixel.FlxSprite;

class RenderEvent {
	public var beat:Int;
	public var sprite:FlxSprite;

	public function new(beat:Int, sprite:FlxSprite) {
		this.beat = beat;
		this.sprite = sprite;
	}
}
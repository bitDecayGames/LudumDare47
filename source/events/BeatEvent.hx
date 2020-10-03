package events;

import entities.Ship;
import flixel.FlxSprite;

class BeatEvent {
	public var impactBeat:Int;
	public var speed:Float;
	public var sprite:Ship;

	public function new(beat:Int, speed:Float, spr:Ship) {
		impactBeat = beat;
		this.speed = speed;
		sprite = spr;
		sprite.speed = speed;
	}
}
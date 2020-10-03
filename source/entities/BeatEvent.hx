package entities;

import flixel.FlxSprite;

class BeatEvent {
	public var impactBeat:Int;
	public var speed:Float;
	public var sprite:FlxSprite;

	public function new(beat:Int, speed:Float, spr:FlxSprite) {
		impactBeat = beat;
		this.speed = speed;
		sprite = spr;
	}
}
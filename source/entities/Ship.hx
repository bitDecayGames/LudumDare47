package entities;

import flixel.FlxSprite;

class Ship extends FlxSprite {
	public function new(x:Float, y:Float) {
		super(x, y);
		loadGraphic(AssetPaths.player__png, true, 90, 135);
		animation.add("idle", [0]);
		animation.play("idle");
	}
}
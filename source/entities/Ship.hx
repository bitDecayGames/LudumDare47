package entities;

import flixel.FlxSprite;

class Ship extends FlxSprite {

	public var speed:Float = 0;
	public var startY:Float = 0;
	public var beat:Int = 0;

	public function new(x:Float, y:Float) {
		super(x, y);
		loadGraphic(AssetPaths.player__png, true, 90, 135);
		animation.add("idle", [0]);
		animation.play("idle");
		offset.set(0, height);
	}

	override public function update(delta:Float) {
		super.update(delta);
	}
}
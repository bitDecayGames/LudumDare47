package entities;

import flixel.FlxSprite;
import flixel.math.FlxPoint;

using extensions.FlxObjectExt;

class Ship extends FlxSprite {

	public var speed:Float = 0;
	public var startY:Float = 0;
	public var beat:Int = 0;

	var hitbox = new FlxPoint(80, 100);

	public function new(x:Float, y:Float) {
		super(x, y);
		loadGraphic(AssetPaths.ship0__png, true, 90, 135);
		offset.set((width - hitbox.x) / 2, height - hitbox.y);

		setSize(hitbox.x, hitbox.y);
		this.setMidpoint(x, y);

		animation.add("idle", [0]);
		animation.play("idle");
	}

	override public function update(delta:Float) {
		super.update(delta);
	}
}
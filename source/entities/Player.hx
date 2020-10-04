package entities;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import actions.Actions;

using extensions.FlxObjectExt;

class Player extends RhythmSprite {
	var actions = new Actions();

	var hitbox = new FlxPoint(80, 110);

	public function new(x:Float, y:Float) {
		super(x, y);

		loadGraphic(AssetPaths.player__png, true, 90, 135, true);
		offset.set((width - hitbox.x) / 2, 5);

		setSize(hitbox.x, hitbox.y);
		this.setMidpoint(x, y);

		animation.add("idle", [0]);
		animation.play("idle");
	}

	override public function update(delta:Float) {
		super.update(delta);
	}

	override public function beat() {

	}
}
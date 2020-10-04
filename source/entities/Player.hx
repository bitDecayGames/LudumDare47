package entities;

import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import actions.Actions;

using extensions.FlxObjectExt;

class Player extends FlxSpriteGroup {
	var actions = new Actions();

	var hitbox = new FlxPoint(60, 90);

	var noseBuffer = 5;

	var ship:ParentedSprite;
	var jets:ParentedSprite;

	public function new(x:Float, y:Float) {
		super(x, y);
		ship = new ParentedSprite(this);
		ship.loadGraphic(AssetPaths.player__png, true, 90, 135, true);
		ship.setSize(hitbox.x, hitbox.y);
		ship.offset.set(15, noseBuffer);
		this.setMidpoint(x, y);
		ship.animation.add("idle", [0]);
		ship.animation.play("idle");
		add(ship);
		jets = new ParentedSprite(this);
		jets.loadGraphic(AssetPaths.jets__png, true, 38, 80);
		jets.setPosition(11, 106);
		jets.allowCollisions = 0;

		jets.animation.add("idle", [0]);
		jets.animation.play("idle");
		add(jets);
	}

	override public function update(delta:Float) {
		super.update(delta);
	}
}
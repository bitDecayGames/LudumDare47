package entities;

import shaders.NormalMapShader;
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

	public var ship:ParentedSprite;

	var jets:ParentedSprite;

	var _shader:NormalMapShader;

	public function new(x:Float, y:Float) {
		super(x, y);
		_shader = new NormalMapShader(new FlxSprite(AssetPaths.player_n__png));
		ship = new ParentedSprite(this);
		ship.loadGraphic(AssetPaths.player__png, true, 90, 135, true);
		ship.setSize(hitbox.x, hitbox.y);
		ship.offset.set(15, noseBuffer);
		ship.shader = _shader;
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

	public function setLightPosition(lightPos:FlxPoint) {
		_shader.setLightPosition(new FlxPoint((lightPos.x - ship.x) / (ship.frameWidth * 3), (lightPos.y - ship.y) / ship.frameHeight));
	}
}

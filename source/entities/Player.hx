package entities;

import shaders.NormalMapShader;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import actions.Actions;

using extensions.FlxObjectExt;

class Player extends FlxSpriteGroup {
	var actions = new Actions();

	var hitbox = new FlxPoint(45, 90);

	var noseBuffer = 5;

	public var ship:ParentedSprite;

	var jets:ParentedSprite;

	var _shader:NormalMapShader;
	var pulseTarget:Float;

	public function new(x:Float, y:Float) {
		super(x, y);
		_shader = new NormalMapShader(new FlxSprite(AssetPaths.player_n__png));
		ship = new ParentedSprite(this);
		ship.loadGraphic(AssetPaths.player__png, true, 90, 135, true);
		ship.setSize(hitbox.x, hitbox.y);
		ship.offset.set(22.5, noseBuffer);
		ship.shader = _shader;
		this.setMidpoint(x, y);
		ship.animation.add("idle", [0]);
		ship.animation.play("idle");
		add(ship);
		jets = new ParentedSprite(this);
		jets.loadGraphic(AssetPaths.jets__png, true, 38, 80);
		jets.setPosition(11-7.5, 106);
		jets.allowCollisions = 0;

		jets.animation.add("idle", [for(i in 0...11) i]);
		jets.animation.play("idle");
		add(jets);
		newTarget();
	}

	private function newTarget() {
		pulseTarget = FlxG.random.float(0.9, 1.1);
	}

	override public function update(delta:Float) {
		super.update(delta);

		if (scale.x != pulseTarget) {
			var diff = pulseTarget - scale.x;
			var change = (diff) * delta;
			scale.add(change, change);

			if (Math.abs(scale.x - pulseTarget) < 0.05) {
				newTarget();
			}
		}
	}

	public function setLightPositions(lights:Array<FlxPoint>) {
		_shader.setLightPositions([for (p in lights) {
			adjustPoint(p);
		}]);
	}

	private var refPoint = FlxPoint.get();

	private function adjustPoint(p:FlxPoint):FlxPoint {
		refPoint = ship.getPosition(refPoint);
		refPoint.subtractPoint(ship.offset);
		// multiply frame width here by 3 because this coordinate is relative  to the full loaded bitmap image
		var ret = new FlxPoint((p.x - refPoint.x) / (ship.frameWidth * 3), (p.y - refPoint.y) / ship.frameHeight);
		return ret;
	}

	public function setAmbientRatio(ratio:Float) {
		_shader.setAmbientRatio(ratio);
	}
}

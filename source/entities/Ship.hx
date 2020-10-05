package entities;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import shaders.NormalMapShader;

using extensions.FlxObjectExt;

class Ship extends FlxSpriteGroup {
	public var speed:Float = 0;
	public var startY:Float = 0;
	public var beat:Int = 0;

	var hitbox = new FlxPoint(80, 100);

	public var body:ParentedSprite;
	public var jets:ParentedSprite;

	var _shader:NormalMapShader;
	var pulseTarget:Float;

	public function new(x:Float, y:Float, forceShipIndex:Int = -1) {
		super(x, y);

		if (forceShipIndex < 0) {
			var heads = FlxG.random.int(0, 1) == 0;
			if (heads) {
				createShip0();
			} else {
				createShip1();
			}
		} else {
			switch (forceShipIndex) {
				case 0:
					createShip0();
				case 1:
					createShip1();
				default:
					createShip0();
			}
		}

		newTarget();
	}

	private function createShip0() {
		_shader = new NormalMapShader(new FlxSprite(AssetPaths.ship0_n__png));
		body = new ParentedSprite(this);
		body.loadGraphic(AssetPaths.ship0__png, true, 90, 135);
		body.setSize(hitbox.x, hitbox.y);
		body.offset.set(5, body.height - hitbox.y + 35);
		this.setMidpoint(x - body.width / 2, y);
		body.animation.add("idle", [0]);
		body.animation.play("idle");
		body.shader = _shader;
		add(body);

		jets = new ParentedSprite(this);
		jets.loadGraphic(AssetPaths.jetsShip0__png, true, 45, 80);
		jets.setPosition(17, 122 - 35);
		jets.allowCollisions = 0;

		jets.animation.add("idle", [for(i in 0...11) i]);
		jets.animation.play("idle");
		add(jets);
	}

	private function createShip1() {
		_shader = new NormalMapShader(new FlxSprite(AssetPaths.ship1_n__png));
		body = new ParentedSprite(this);
		body.loadGraphic(AssetPaths.ship1__png, true, 90, 135);
		body.setSize(hitbox.x, hitbox.y);
		body.offset.set(5, body.height - hitbox.y + 35);
		this.setMidpoint(x - body.width / 2, y);
		body.animation.add("idle", [0]);
		body.animation.play("idle");
		body.shader = _shader;
		add(body);

		jets = new ParentedSprite(this);
		jets.loadGraphic(AssetPaths.jetsShip1__png, true, 52, 80);
		jets.setPosition(14, 96);
		jets.allowCollisions = 0;

		jets.animation.add("idle", [for(i in 0...11) i]);
		jets.animation.play("idle");
		add(jets);
	}

	private function newTarget() {
		pulseTarget = FlxG.random.float(0.9, 1.1);
	}

	override public function update(delta:Float) {
		super.update(delta);

		if (scale.x != pulseTarget) {
			var diff = pulseTarget - scale.x;
			var change = (diff / 2) * delta;
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
		refPoint = body.getPosition(refPoint);
		refPoint.subtractPoint(body.offset);
		var ret = new FlxPoint((p.x - refPoint.x) / (body.frameWidth * 3), (p.y - refPoint.y) / body.frameHeight);
		return ret;
	}

	public function setAmbientRatio(ratio:Float) {
		_shader.setAmbientRatio(ratio);
	}
}

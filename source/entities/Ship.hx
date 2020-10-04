package entities;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

using extensions.FlxObjectExt;

class Ship extends FlxSpriteGroup {

	public var speed:Float = 0;
	public var startY:Float = 0;
	public var beat:Int = 0;

	var hitbox = new FlxPoint(80, 100);

	var body:ParentedSprite;
	var jets:ParentedSprite;

	var pulseTarget:Float;

	public function new(x:Float, y:Float) {
		super(x, y);
		body = new ParentedSprite(this);
		body.loadGraphic(AssetPaths.ship0__png, true, 90, 135);
		body.setSize(hitbox.x, hitbox.y);
		body.offset.set(5, body.height - hitbox.y + 35);
		this.setMidpoint(x - body.width/2, y);
		body.animation.add("idle", [0]);
		body.animation.play("idle");
		add(body);

		jets = new ParentedSprite(this);
		jets.loadGraphic(AssetPaths.jetsShip0__png, true, 45, 80);
		jets.setPosition(17, 122 - 35);
		jets.allowCollisions = 0;

		jets.animation.add("idle", [0]);
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
			var change = (diff / 2) * delta;
			scale.add(change, change);

			if (Math.abs(scale.x - pulseTarget) < 0.05) {
				newTarget();
			}
		}
	}
}
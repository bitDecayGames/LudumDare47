package states;

import entities.Ship;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxPath;
import flixel.FlxState;
import entities.MovingPath;

using extensions.FlxObjectExt;

class PathTest extends FlxState {

	var path:MovingPath;

	var sprite:FlxSprite;

    override public function create():Void {
		super.create();
		path = new MovingPath(
			FlxPoint.get(0, 300),
			[
				FlxPoint.get(250, 0),
				FlxPoint.get(250, -150),
				FlxPoint.get(150, -250),
				FlxPoint.get(150, -450)
			]);
		sprite = new FlxSprite(AssetPaths.go__png);
		sprite.setMidpoint(250, 0);
		add(sprite);

		FlxG.watch.add(sprite, "x", "x: ");
		FlxG.watch.add(sprite, "y", "y: ");

		// Note: Paths automatically have the MIDPOINT follow the path
		sprite.path = path.start(50, FlxPath.FORWARD);
		// sprite.path = path.start(100, FlxPath.YOYO | FlxPath.HORIZONTAL_ONLY);

		FlxG.camera.bgColor = FlxColor.BROWN;

		path.debugColor = FlxColor.PINK;

		var ship = new Ship(100, 100);
		add(ship);
    }

	override public function draw():Void {
		super.draw();

		#if !FLX_NO_DEBUG
		path.drawDebug();
		#end
	}

	var kickedOff:Bool;

	var scale:Float = 1;
	var increase:Bool = true;

    override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (!kickedOff) {
			FlxTween.tween(sprite, {y: sprite.y + 800}, 4);
			kickedOff = true;
		}

		if (increase) {
			scale += 1 * elapsed;
			if (scale >= 2) {
				scale = 2;
				increase = false;
			}
		} else if (!increase) {
			scale -= 1 * elapsed;
			if (scale <= 1) {
				scale = 1;
				increase = true;
			}
		}
		sprite.scale.set(scale, scale);
    }
}
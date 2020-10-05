package entities;

import flixel.FlxSprite;

class Light extends FlxSprite {

	public var levelOffset:Float = 0;

	public function new(x:Float, y:Float) {
		super(x, y, AssetPaths.lightbulb__png);

		#if !FLX_NO_DEBUG
		visible = true;
		#else
		visible = false;
		#end
	}
}
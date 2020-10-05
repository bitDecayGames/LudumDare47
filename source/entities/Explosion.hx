package entities;

import flixel.FlxSprite;

class Explosion extends FlxSprite {
	public function new(playerX:Float, playerY:Float) {
		super(playerX - 50, playerY - 850);
		loadGraphic(AssetPaths.shipExplode__png, true, 160, 980, true);
		animation.add("explode", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 14, false);
		animation.play("explode");
	}
}

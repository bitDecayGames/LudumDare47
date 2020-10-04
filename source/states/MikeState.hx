package states;

import flixel.math.FlxPoint;
import entities.Player;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import shaders.MosaicEffect;
import shaders.NormalMapShader;
import flixel.tweens.FlxTween;

class MikeState extends FlxState {
	public var lightSource:FlxSprite;
	public var lightMoveSpeed:Float = 8.0;
	public var player:Player;

	override public function create() {
		super.create();

		player = new Player(0, 0);
		player.x = FlxG.width / 2.0 - player.width / 2.0;
		player.y = FlxG.height / 2.0 - player.height / 2.0;
		add(player);

		lightSource = new FlxSprite(AssetPaths.lightbulb__png);
		add(lightSource);

		FmodManager.PauseSong();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		moveLightbulb();

		player.setLightPosition(lightSource.getPosition());
	}

	private function moveLightbulb() {
		if (FlxG.keys.pressed.LEFT) {
			lightSource.x -= lightMoveSpeed;
		}

		if (FlxG.keys.pressed.RIGHT) {
			lightSource.x += lightMoveSpeed;
		}

		if (FlxG.keys.pressed.UP) {
			lightSource.y -= lightMoveSpeed;
		}

		if (FlxG.keys.pressed.DOWN) {
			lightSource.y += lightMoveSpeed;
		}

		if (FlxG.keys.pressed.ONE) {
			lightSource.x = 0;
			lightSource.y = 0;
		}

		if (FlxG.keys.pressed.TWO) {
			lightSource.x = FlxG.width / 2.0;
			lightSource.y = FlxG.height / 2.0;
		}

		if (FlxG.keys.pressed.THREE) {
			lightSource.x = FlxG.width;
			lightSource.y = FlxG.height;
		}

		if (FlxG.keys.pressed.FOUR) {
			lightSource.x = FlxG.width;
			lightSource.y = 0;
		}

		if (FlxG.keys.pressed.FIVE) {
			lightSource.x = 0;
			lightSource.y = FlxG.height;
		}
	}
}

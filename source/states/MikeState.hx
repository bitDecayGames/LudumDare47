package states;

import flixel.math.FlxPoint;
import entities.Player;
import entities.Ship;
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
	public var ship0:Ship;
	public var ship1:Ship;

	override public function create() {
		super.create();

		var x = 250;
		var y = 0;

		player = new Player(x, y);
		add(player);
		x += 60;
		y += 150;

		ship0 = new Ship(x, y, 0);
		add(ship0);
		x += 30;
		y += 150;

		ship1 = new Ship(x, y, 1);
		add(ship1);

		lightSource = new FlxSprite(AssetPaths.lightbulb__png);

		x = -180;
		y = 0;
		add(new FlxSprite(x, y, AssetPaths.player_n__png));
		y += 150;
		add(new FlxSprite(x, y, AssetPaths.ship0_n__png));
		y += 150;
		add(new FlxSprite(x, y, AssetPaths.ship1_n__png));

		add(lightSource);

		FmodManager.PauseSong();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		moveLightbulb();

		var lightPos = lightSource.getPosition();
		player.setLightPosition(lightPos);
		ship0.setLightPosition(lightPos);
		ship1.setLightPosition(lightPos);
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

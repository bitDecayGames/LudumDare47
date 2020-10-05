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
	public var lightSource2:FlxSprite;
	public var lightMoveSpeed:Float = 8.0;
	public var player:Player;
	public var ship0:Ship;
	public var ship1:Ship;

	public var lights:Array<FlxSprite>;

	override public function create() {
		super.create();

		var x = 125;
		var y = 250;

		player = new Player(x, y);
		player.setAmbientRatio(0.2);
		add(player);
		x += 60;
		y += 150;

		ship0 = new Ship(x, y, 0);
		ship0.setAmbientRatio(0.2);
		add(ship0);
		x += 30;
		y += 150;

		ship1 = new Ship(x, y, 1);
		ship1.setAmbientRatio(0.2);
		add(ship1);

		lights = new Array<FlxSprite>();
		for (i in 0...2) {
			addLight();
		}

		lightSource = new FlxSprite(AssetPaths.lightbulb__png);
		lightSource2 = new FlxSprite(AssetPaths.lightbulb__png);

		// x = -180;
		// y = 0;
		// add(new FlxSprite(x, y, AssetPaths.player_n__png));
		// y += 150;
		// add(new FlxSprite(x, y, AssetPaths.ship0_n__png));
		// y += 150;
		// add(new FlxSprite(x, y, AssetPaths.ship1_n__png));

		// add(lightSource);
		add(lightSource2);

		FmodManager.PauseSong();

		FlxG.watch.addMouse();
	}

	private function superTween(light:FlxSprite) {
		FlxTween.linearMotion(light,
			light.x,
			light.y,
			FlxG.random.float(0, FlxG.width),
			FlxG.random.float(0, FlxG.height),
			FlxG.random.float(0.5, 5)).onComplete = (t) -> {
				// light.visible = FlxG.random.bool(50);
				superTween(light);
			};
	}

	private function addLight() {
		var newLight = new FlxSprite(AssetPaths.lightbulb__png);
		lights.push(newLight);
		superTween(newLight);
		add(newLight);
	}

	private function removeLight() {
		if (lights.length == 0) {
			return;
		}

		lights.remove(cast(remove(lights[lights.length-1]), FlxSprite));
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		moveLightbulb();

		// var lightPos = lightSource.getPosition();
		// var lightPos2 = lightSource2.getPosition();
		// player.setLightPosition(lightPos);
		// ship0.setLightPosition(lightPos);
		// ship1.setLightPosition(lightPos);

		var arr = [for (l in lights) {
			if (l.visible) {
				l.getMidpoint();
			}
		}];
		arr.insert(0, lightSource2.getMidpoint());
		player.setLightPositions(arr);
		ship0.setLightPositions(arr);
		ship1.setLightPositions(arr);
	}

	private function moveLightbulb() {
		if (FlxG.keys.pressed.UP) {
			lightSource.y -= lightMoveSpeed;
		}
		if (FlxG.keys.pressed.DOWN) {
			lightSource.y += lightMoveSpeed;
		}
		if (FlxG.keys.pressed.LEFT) {
			lightSource.x -= lightMoveSpeed;
		}
		if (FlxG.keys.pressed.RIGHT) {
			lightSource.x += lightMoveSpeed;
		}

		if (FlxG.keys.pressed.W) {
			lightSource2.y -= lightMoveSpeed;
		}
		if (FlxG.keys.pressed.S) {
			lightSource2.y += lightMoveSpeed;
		}
		if (FlxG.keys.pressed.A) {
			lightSource2.x -= lightMoveSpeed;
		}
		if (FlxG.keys.pressed.D) {
			lightSource2.x += lightMoveSpeed;
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

		if (FlxG.keys.justPressed.M) {
			addLight();
		}
		if (FlxG.keys.justPressed.N) {
			removeLight();
		}
	}
}

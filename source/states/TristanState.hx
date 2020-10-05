package states;

import events.BeatEvent;
import events.RenderEvent;
import entities.Ship;
import haxefmod.FmodEvents.FmodCallback;
import flixel.system.FlxAssets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import shaders.MapShader;
import flixel.addons.ui.FlxSlider;

class TristanState extends FlxState
{
	var map:FlxOgmo3Loader;
	var tiles:FlxTilemap;
	var shader = new MapShader();
	var nextSliderY:Int;
	var xPos:Float;
	var yPos:Float;

	var currentBeat:Int = 0;
	var beatEvents:Array<BeatEvent> = [];
	var renderEvents:Map<Int, Array<RenderEvent>> = new Map();
	var numLights:Int = 2;

	override public function create()
	{
		super.create();
		//FmodManager.PlaySong(FmodSongs.LetsGo);

		// map = new FlxOgmo3Loader(AssetPaths.turnBasedRPG__ogmo, AssetPaths.room_001__json);
		// tiles = map.loadTilemap(AssetPaths.tiles__png, "walls");
		// //tiles.follow();
		// tiles.setTileProperties(1, FlxObject.NONE);
		// tiles.setTileProperties(2, FlxObject.ANY);
		// add(tiles);


		var barrier = new FlxSprite(FlxG.width / 2, 0, AssetPaths.standAloneBarrier__png);
		add(barrier);
		barrier.shader = shader;

		FlxG.cameras.bgColor = FlxColor.BLACK;

		// Create some UI
		var UI_WIDTH:Int = 200;
		var UI_HEIGHT:Int = 245;
		var UI_POS_X:Int = FlxG.width - UI_WIDTH;
		var UI_POS_Y:Int = FlxG.height - UI_HEIGHT;

		var uiBackground:FlxSprite = new FlxSprite(UI_POS_X, UI_POS_Y);
		uiBackground.makeGraphic(UI_WIDTH, UI_HEIGHT, FlxColor.WHITE);
		uiBackground.alpha = 0.85;

		var title:FlxText = new FlxText(UI_POS_X, UI_POS_Y + 2, UI_WIDTH, "Lighting Controls");
		title.setFormat(null, 16, FlxColor.YELLOW, CENTER, OUTLINE_FAST, FlxColor.BLACK);

		var xPosSlider:FlxSlider = new FlxSlider(this, "xPos", FlxG.width - 180, UI_POS_Y + 50, 0, 1, 150);
		xPosSlider.nameLabel.text = "Light Source X";

		var yPosSlider:FlxSlider = new FlxSlider(this, "yPos", FlxG.width - 180, UI_POS_Y + 100, 0, 1, 150);
		yPosSlider.nameLabel.text = "Light Source Y";

		// Add all the stuff in correct order
		add(uiBackground);
		add(title);
		add(xPosSlider);
		add(yPosSlider);
		//adjustLights();
	}

	private function adjustLights()
	{
		if (this.numLights == 1) {
			this.numLights = 2;
		}
		else {
			this.numLights = 1;
		}
		this.shader.numLights.value = [this.numLights];
	}
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		this.shader.lightPos1.value = [xPos, yPos];
		this.shader.lightPos2.value = [0.5, 0.5];
		this.shader.fireRadius.value = [0.2];

		if (FlxG.keys.justPressed.L)
		{
			trace("numLights: ", this.numLights);
			//adjustLights();
		}

		FmodManager.Update();

	}
}

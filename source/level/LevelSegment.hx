package level;

import flixel.tile.FlxTilemap;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;

// Composite Tilemap without needing limtations of a group.
class LevelSegment {
	var xAlign = 55;

	var track:FlxTilemap;
	var tileMaps:Array<FlxTilemap> = [];

	public function new() {}

	public function load(ogmoFile:String, levelFile:String) {
		var map = new FlxOgmo3Loader(ogmoFile, levelFile);

		track = map.loadTilemap(AssetPaths.tiles__png, "track");

		// First empty tile
		track.setTileProperties(0, FlxObject.NONE);
		// All other trigger collisons
		for (i in 1...128) {
			track.setTileProperties(i, FlxObject.ANY);
		}
		addToTileMaps(track);

		var decoration = map.loadTilemap(AssetPaths.tiles__png, "lines and lanes");
		addToTileMaps(decoration);
	}

	public function getTrack():FlxTilemap {
		return track;
	}

	public function getHeight():Float {
		if (tileMaps.length < 1) {
			return 0;
		}
		return tileMaps[0].height;
	}

	public function getY():Float {
		if (tileMaps.length < 1) {
			return 0;
		}
		return tileMaps[0].y;
	}

	public function addToState(state:FlxState) {
		for (tm in tileMaps) {
			state.add(tm);
		}
	}

	public function setY(value:Float) {
		for (tm in tileMaps) {
			tm.y = value;
		}
	}

	public function kill() {
		for (tm in tileMaps) {
			tm.kill();
		}
	}

	public function revive() {
		for (tm in tileMaps) {
			tm.revive();
		}
	}

	private function addToTileMaps(tm:FlxTilemap) {
		tm.kill();
		tm.x -= xAlign;
		tileMaps.push(tm);
	}
}

package level;

import flixel.tile.FlxTilemap;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import events.BeatEvent;
import entities.Ship;

// Composite Tilemap without needing limtations of a group.
class LevelSegment {
	var xAlign = 55;

	var track:FlxTilemap;
	var tileMaps:Array<FlxTilemap> = [];
	var shipEntityData:Array<EntityData> = [];

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

		map.loadEntities(function loadEntity(entity:EntityData) {
			// trace("entity", entity.name);
			if (entity.name == "slowShip" || entity.name == "fastShip") {
				shipEntityData.push(entity);
				return;
			}
			throw 'Unrecognized ships entity name: ${entity.name}';
		}, "ships");
	}

	public function generateBeatEvents(currentBeat:Int, pixelsPerBeat:Int):Array<BeatEvent> {
		var magicEntityX = 15;
		var beatEvents:Array<BeatEvent> = [];

		for (entity in shipEntityData) {
			var beat = Std.int((entity.y / pixelsPerBeat) + currentBeat);
			// trace("beat event created for beat", beat);
			beatEvents.push(new BeatEvent(beat, entity.values.speed, new Ship(entity.x - magicEntityX, 0)));
		}

		// trace(beatEvents.length, "beat events generated on curent beat", currentBeat);
		return beatEvents;
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

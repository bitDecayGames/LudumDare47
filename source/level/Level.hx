package level;

import events.BeatEvent;
import entities.Ship;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;

class Level {
	public var bpm: Float = 0.0;
	public var pixelsPerBeat: Int = 0;

	public var beatEvents:Array<BeatEvent> = [];
	public var track:FlxTilemap;
	public var track2:FlxTilemap;
	public var background:FlxSprite;

	public function new(bpm: Float, pixelsPerBeat: Int) {
		this.bpm = bpm;
		this.pixelsPerBeat = pixelsPerBeat;

		background = new FlxSprite();
		background.loadGraphic(AssetPaths.nebula0__png, false, 560, 1260, true);
	}

    public function initDefaultBeatEvents(laneCoords: Array<Float>) {
		beatEvents.push(new BeatEvent(10, 1, new Ship(laneCoords[0], 0)));
		beatEvents.push(new BeatEvent(10, 1, new Ship(laneCoords[1], 0)));
		beatEvents.push(new BeatEvent(10, 1, new Ship(laneCoords[3], 0)));
		beatEvents.push(new BeatEvent(10, 1, new Ship(laneCoords[4], 0)));

		beatEvents.push(new BeatEvent(14, 1, new Ship(laneCoords[2], 0)));

		beatEvents.push(new BeatEvent(20, 1, new Ship(laneCoords[1], 0)));
		beatEvents.push(new BeatEvent(20, 1, new Ship(laneCoords[2], 0)));
		beatEvents.push(new BeatEvent(20, 1, new Ship(laneCoords[3], 0)));
		beatEvents.push(new BeatEvent(20, 1, new Ship(laneCoords[4], 0)));

		beatEvents.push(new BeatEvent(24, 1, new Ship(laneCoords[0], 0)));
		beatEvents.push(new BeatEvent(25, 1, new Ship(laneCoords[1], 0)));
		beatEvents.push(new BeatEvent(26, 1, new Ship(laneCoords[2], 0)));
		beatEvents.push(new BeatEvent(27, 1, new Ship(laneCoords[3], 0)));

		beatEvents.push(new BeatEvent(33, 1, new Ship(laneCoords[4], 0)));
		beatEvents.push(new BeatEvent(34, 1, new Ship(laneCoords[3], 0)));
		beatEvents.push(new BeatEvent(35, 1, new Ship(laneCoords[2], 0)));
		beatEvents.push(new BeatEvent(36, 1, new Ship(laneCoords[1], 0)));

		beatEvents.push(new BeatEvent(45, 1, new Ship(laneCoords[0], 0)));
		beatEvents.push(new BeatEvent(45, 1, new Ship(laneCoords[1], 0)));
		beatEvents.push(new BeatEvent(45, 1, new Ship(laneCoords[3], 0)));
		beatEvents.push(new BeatEvent(45, 1, new Ship(laneCoords[4], 0)));

		beatEvents.push(new BeatEvent(47, 1, new Ship(laneCoords[1], 0)));
		beatEvents.push(new BeatEvent(47, 1, new Ship(laneCoords[3], 0)));

		beatEvents.push(new BeatEvent(49, 1, new Ship(laneCoords[1], 0)));
		beatEvents.push(new BeatEvent(49, 1, new Ship(laneCoords[3], 0)));

		beatEvents.push(new BeatEvent(53, 2, new Ship(laneCoords[2], 0)));

		beatEvents.push(new BeatEvent(55, 1, new Ship(laneCoords[0], 0)));
		beatEvents.push(new BeatEvent(55, 1, new Ship(laneCoords[1], 0)));
		beatEvents.push(new BeatEvent(55, 1, new Ship(laneCoords[3], 0)));
		beatEvents.push(new BeatEvent(55, 1, new Ship(laneCoords[4], 0)));
	}

	public function addToState(state: FlxState) {
		state.add(background);
		state.add(track);

		state.add(track2);
	}
	
	public function loadOgmoMap(ogmoFile:String, levelFile:String) {
		var map = new FlxOgmo3Loader(ogmoFile, levelFile);

		track = map.loadTilemap(AssetPaths.tiles__png, "Track");
		track.x -= 55;
		track.y = -track.height + FlxG.height;

		var newMapWhoDis = new FlxOgmo3Loader(ogmoFile, AssetPaths.segment01__json);
		track2 = newMapWhoDis.loadTilemap(AssetPaths.tiles__png, "Track");
		track2.x = track.x;
		track2.y = FlxG.height;
		// TODO May not need to do this
		// FlxG.worldBounds.set(0, 0, walls.width, walls.height);
		// groundType = map.loadTilemap(AssetPaths.groundTypes__png, "GroundType");
		// groundType.setTileProperties(1, FlxObject.ANY, setPlayerGroundType("concrete"));
		// groundType.setTileProperties(2, FlxObject.ANY, setPlayerGroundType("grass"));
		// groundType.setTileProperties(3, FlxObject.ANY, setPlayerGroundType("metal"));

		// map.loadEntities(function loadEntity(entity:EntityData) {
		// 	switch (entity.name) {
		// 		case "Ship":
		// 			var beat = Std.int(entity.y / pixelsPerBeat);
		// 			var speed = 1; // TODO Will this be on entity metadata?
		// 			beatEvents.push(new BeatEvent(beat, speed, new Ship(entity.x, 0)));
		// 			return;
		// 		default:
		// 			throw 'Unrecognized entity name: ${entity.name}';
		// 	}
		// }, "Entities");
	}

	public function update(elapsed:Float) {
		var bps = bpm / 60;
		var dy = elapsed * bps * pixelsPerBeat * 4;
		track.y += dy;
		if (track.y >= 0) {
			track2.y = track.y - track2.height;
		}

		track2.y += dy;
		if (track2.y >= 0) {
			track.y = track2.y - track.height;
		}
	}
}
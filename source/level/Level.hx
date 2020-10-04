package level;

import events.BeatEvent;
import entities.Ship;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;
import flixel.FlxState;

class Level {
	public var bpm: Float = 0.0;
	public var pixelsPerBeat: Int = 0;

	public var beatEvents:Array<BeatEvent> = [];
	public var walls:FlxTilemap;
	public var background:FlxTilemap;

	public function new(bpm: Float, pixelsPerBeat: Int) {
		this.bpm = bpm;
		this.pixelsPerBeat = pixelsPerBeat;
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
		// state.add(background);
		// state.add(walls);
	}
	
	public function loadOgmoMap(ogmoFile:String, levelFile:String, bpm: Float) {
		var map = new FlxOgmo3Loader(ogmoFile, levelFile);

		// background = map.loadTilemap(AssetPaths.cityTiles__png, "Ground");
		// walls = map.loadTilemap(AssetPaths.collisions__png, "Walls");
		// FlxG.worldBounds.set(0, 0, walls.width, walls.height);
		// groundType = map.loadTilemap(AssetPaths.groundTypes__png, "GroundType");
		// groundType.setTileProperties(1, FlxObject.ANY, setPlayerGroundType("concrete"));
		// groundType.setTileProperties(2, FlxObject.ANY, setPlayerGroundType("grass"));
		// groundType.setTileProperties(3, FlxObject.ANY, setPlayerGroundType("metal"));

		map.loadEntities(function loadEntity(entity:EntityData) {
			switch (entity.name) {
				case "Ship":
					var beat = Std.int(entity.y / pixelsPerBeat);
					var speed = 1; // TODO Will this be on entity metadata?
					beatEvents.push(new BeatEvent(beat, speed, new Ship(entity.x, 0)));
					return;
				default:
					throw 'Unrecognized entity name: ${entity.name}';
			}
		}, "Entities");
	}
}
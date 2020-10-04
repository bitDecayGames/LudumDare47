package level;

import events.BeatEvent;
import entities.Ship;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;

class Level {
	public var bpm: Float = 0.0;

	public var beatEvents:Array<BeatEvent> = [];
	public var walls:FlxTilemap;
	public var background:FlxTilemap;

	public static function createFromOgmoFile(ogmoFile:String, levelFile:String, bpm: Float): Level {
		var map = new FlxOgmo3Loader(ogmoFile, levelFile);
		var level = new Level(bpm);
		level.load(map);
		return level;
	}

	public function new(bpm: Float) {
		this.bpm = bpm;
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
	
	private function load(map: FlxOgmo3Loader) {
		// background = map.loadTilemap(AssetPaths.cityTiles__png, "Ground");
		// walls = map.loadTilemap(AssetPaths.collisions__png, "Walls");
		// FlxG.worldBounds.set(0, 0, walls.width, walls.height);
		// groundType = map.loadTilemap(AssetPaths.groundTypes__png, "GroundType");
		// groundType.setTileProperties(1, FlxObject.ANY, setPlayerGroundType("concrete"));
		// groundType.setTileProperties(2, FlxObject.ANY, setPlayerGroundType("grass"));
		// groundType.setTileProperties(3, FlxObject.ANY, setPlayerGroundType("metal"));

		// map.loadEntities(function loadEntity(entity:EntityData) {
		// 	switch (entity.name) {
		// 		case "PlayerSpawn":
		// 			player = new Player(entity.x, entity.y);
		// 			return;
		// 		case "Checkpoint":
		// 			var checkpoint = checkpointManager.createCheckpoint();
		// 			checkpoint.x = entity.x;
		// 			checkpoint.y = entity.y;
		// 			triggers.add(checkpoint);
		// 			return;
		// 		case "Objective":
		// 			var objective = objectiveManager.createObjective(entity.values.description, entity.values.index);
		// 			objective.x = entity.x;
		// 			objective.y = entity.y;
		// 			triggers.add(objective);
		// 			return;
		// 		default:
		// 			throw 'Unrecognized actor type ${entity.name}';
		// 	}
		// }, "Entities");
	}
}
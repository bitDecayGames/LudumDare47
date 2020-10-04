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

	var xAlign = 55;

	public var beatEvents:Array<BeatEvent> = [];

	public var trackSegments:Array<FlxTilemap> = [];

	// intended to be a guide for us to use to rewind properly
	public var visitedSegments:Array<Int> = [];
	public var activeTrack:FlxTilemap;
	public var queuedTrack:FlxTilemap;

	public var background:FlxSprite;
	public var groundSpeed:Float = 4;

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

		for (t in trackSegments) {
			state.add(t);
		}
	}

	public function loadOgmoMap(ogmoFile:String, levelFile:String) {
		var map = new FlxOgmo3Loader(ogmoFile, levelFile);

		var track = map.loadTilemap(AssetPaths.tiles__png, "Track");
		addSegment(track);

		var newMapWhoDis = new FlxOgmo3Loader(ogmoFile, AssetPaths.segment01__json);
		var track2 = newMapWhoDis.loadTilemap(AssetPaths.tiles__png, "Track");
		addSegment(track2);

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
		queueSegmentIfNeeded();
	}

	private function addSegment(s:FlxTilemap) {
		s.kill();
		s.x -= xAlign;
		trackSegments.push(s);
	}

	public function update(elapsed:Float) {
		var bps = bpm / 60;
		var dy = elapsed * bps * pixelsPerBeat * groundSpeed;
		activeTrack.y += dy;
		queuedTrack.y += dy;

		if (activeTrack.y > FlxG.height) {
			activeTrack.kill();
			activeTrack = queuedTrack;
			queuedTrack = null;
		}

		queueSegmentIfNeeded();
	}

	private function queueSegmentIfNeeded() {

		if (activeTrack == null) {
			// first segment
			activeTrack = trackSegments[0];
			activeTrack.revive();
			activeTrack.y = -activeTrack.height + FlxG.height;
			visitedSegments.push(0);
		}

		if (queuedTrack == null) {
			// TODO: this will be randomized, storing what we visit so we can rewind propery
			if (activeTrack == trackSegments[0]) {
				queuedTrack = trackSegments[1];
				visitedSegments.push(1);
			} else {
				queuedTrack = trackSegments[0];
				visitedSegments.push(0);
			}

			queuedTrack.revive();
			queuedTrack.y = activeTrack.y - queuedTrack.height;
		}
	}
}
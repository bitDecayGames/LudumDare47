package level;

import events.BeatEvent;
import entities.Ship;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;

class Level {
	public var bpm: Float = 0.0;
	public var pixelsPerBeat: Int = 0;

	public var beatEvents:Array<BeatEvent> = [];

	public var nextSegmentToLoad = -1;

	public var levelSegments:Array<LevelSegment> = [];
	public var activeSegment:LevelSegment;
	public var queuedSegment:LevelSegment;

	public var background:FlxSprite;
	public var groundSpeed:Float = 4;

	public var lastRewind:Bool = false;
	public var rewind:Bool = false;

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

		for (ls in levelSegments) {
			ls.addToState(state);
		}
	}

	public function loadOgmoMap() {
		var ogmoFile = AssetPaths.test__ogmo;
		var segments = [
			AssetPaths.segment00__json,
			AssetPaths.segment01__json,
			AssetPaths.segment02__json,
			AssetPaths.segment03__json,
			AssetPaths.segment04__json,
		];
		for (s in segments) {
			var ts = new LevelSegment();
			ts.load(ogmoFile, s);
			levelSegments.push(ts);
		}

		// TODO May not need to do this
		// FlxG.worldBounds.set(0, 0, walls.width, walls.height);

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

		queueSegmentIfNeeded(rewind);	
	}

	public function update(elapsed:Float) {
		var bps = bpm / 60;
		var dy = elapsed * bps * pixelsPerBeat * groundSpeed;

		if (rewind != lastRewind) {
			// need to flip stuff around
			var temp = activeSegment;
			activeSegment = queuedSegment;
			queuedSegment = temp;

			lastRewind = rewind;
		}

		if (rewind) {
			activeSegment.setY(activeSegment.getY() - dy);
			queuedSegment.setY(queuedSegment.getY() - dy);

			if (activeSegment.getY() < -activeSegment.getHeight()) {
				activeSegment.kill();
				activeSegment = queuedSegment;
				queuedSegment = null;
			}
		} else {
			activeSegment.setY(activeSegment.getY() + dy);
			queuedSegment.setY(queuedSegment.getY() + dy);

			if (activeSegment.getY() > FlxG.height) {
				activeSegment.kill();
				activeSegment = queuedSegment;
				queuedSegment = null;
			}
		}

		queueSegmentIfNeeded(rewind);
	}

	public function resetTrack() {
		rewind = false;

		if (activeSegment != null) {
			activeSegment.kill();
			activeSegment = null;
		}

		if (activeSegment != null) {
			activeSegment.kill();
			activeSegment = null;
		}

		nextSegmentToLoad = -1;
		lastRewind = rewind;
		queueSegmentIfNeeded(rewind);
	}

	private function queueSegmentIfNeeded(rewind:Bool) {
		if (activeSegment == null) {
			// first segment
			activeSegment = levelSegments[nextSegmentNum(rewind)];
			activeSegment.revive();
			activeSegment.setY(-activeSegment.getHeight() + FlxG.height);
		}

		if (queuedSegment == null) {
			queuedSegment = levelSegments[nextSegmentNum(rewind)];
			queuedSegment.revive();

			if (rewind) {
				queuedSegment.setY(activeSegment.getY() + activeSegment.getHeight());
			} else {
				queuedSegment.setY(activeSegment.getY() - queuedSegment.getHeight());
			}
		}
	}

	private function nextSegmentNum(rewind:Bool):Int {
		if (rewind) {
			nextSegmentToLoad--;
		} else {
			nextSegmentToLoad++;
		}

		if (nextSegmentToLoad >= levelSegments.length) {
			nextSegmentToLoad -= levelSegments.length;
		}

		if (nextSegmentToLoad < 0) {
			nextSegmentToLoad += levelSegments.length;
		}

		return nextSegmentToLoad;
	}
}
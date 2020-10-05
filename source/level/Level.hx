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

	var xAlign = 55;

	public var beatEvents:Array<BeatEvent> = [];

	public var nextSegmentToLoad = -1;
	public var trackSegments:Array<FlxTilemap> = [];
	public var decorationSegments:Array<FlxTilemap> = [];

	public var activeTrack:FlxTilemap;
	public var activeDecoration:FlxTilemap;
	public var queuedTrack:FlxTilemap;
	public var queuedDecoration:FlxTilemap;

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

		for (t in trackSegments) {
			state.add(t);
		}
		for (d in decorationSegments) {
			state.add(d);
		}
	}

	public function loadOgmoMap() {
		var ogmoFile = AssetPaths.test__ogmo;
		load(ogmoFile, AssetPaths.segment00__json);
		load(ogmoFile, AssetPaths.segment01__json);
		load(ogmoFile, AssetPaths.segment02__json);
		load(ogmoFile, AssetPaths.segment03__json);
		load(ogmoFile, AssetPaths.segment04__json);

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

	private function load(ogmoFile:String, levelFile:String) {
		var map = new FlxOgmo3Loader(ogmoFile, levelFile);

		var track = map.loadTilemap(AssetPaths.tiles__png, "track");
		for (i in 0...128) {
			// TODO How do we determine which tiles are collidable?
			track.setTileProperties(i, FlxObject.NONE);
		}
		addSegment(track);

		var decoration = map.loadTilemap(AssetPaths.tiles__png, "lines and lanes");
		addDecoration(decoration);
	}

	private function addSegment(s:FlxTilemap) {
		s.kill();
		s.x -= xAlign;
		trackSegments.push(s);
	}

	private function addDecoration(d:FlxTilemap) {
		d.kill();
		d.x -= xAlign;
		decorationSegments.push(d);
	}

	public function update(elapsed:Float) {
		var bps = bpm / 60;
		var dy = elapsed * bps * pixelsPerBeat * groundSpeed;

		if (rewind != lastRewind) {
			// need to flip stuff around
			var temp = activeTrack;
			activeTrack = queuedTrack;
			queuedTrack = temp;

			lastRewind = rewind;
		}

		if (rewind) {
			activeTrack.y -= dy;
			activeDecoration.y -= dy;
			queuedTrack.y -= dy;
			queuedDecoration.y -= dy;

			if (activeTrack.y < -activeTrack.height) {
				activeTrack.kill();
				activeTrack = queuedTrack;
				queuedTrack = null;
			}

			if (activeDecoration.y < -activeDecoration.height) {
				activeDecoration.kill();
				activeDecoration = queuedDecoration;
				queuedDecoration = null;
			}
		} else {
			activeTrack.y += dy;
			activeDecoration.y += dy;
			queuedTrack.y += dy;
			queuedDecoration.y += dy;

			if (activeTrack.y > FlxG.height) {
				activeTrack.kill();
				activeTrack = queuedTrack;
				queuedTrack = null;
			}

			if (activeDecoration.y > FlxG.height) {
				activeDecoration.kill();
				activeDecoration = queuedDecoration;
				queuedDecoration = null;
			}
		}

		queueSegmentIfNeeded(rewind);
	}

	public function resetTrack() {
		rewind = false;

		if (activeTrack != null) {
			activeTrack.kill();
			activeTrack = null;
		}

		if (queuedTrack != null) {
			queuedTrack.kill();
			queuedTrack = null;
		}

		nextSegmentToLoad = -1;
		lastRewind = rewind;
		queueSegmentIfNeeded(rewind);
	}

	private function queueSegmentIfNeeded(rewind:Bool) {

		if (activeTrack == null) {
			// first segment
			activeTrack = trackSegments[nextSegmentNum(rewind)];
			activeTrack.revive();
			activeTrack.y = -activeTrack.height + FlxG.height;
		}

		if (activeDecoration == null) {
			// first decoration
			activeDecoration = decorationSegments[nextSegmentToLoad++ % decorationSegments.length];
			activeDecoration.revive();
			activeDecoration.y = -activeDecoration.height + FlxG.height;
		}

		if (queuedTrack == null) {
			queuedTrack = trackSegments[nextSegmentNum(rewind)];
			queuedTrack.revive();

			if (rewind) {
				queuedTrack.y = activeTrack.y + activeTrack.height;
			} else {
				queuedTrack.y = activeTrack.y - queuedTrack.height;
			}
		}

		if (queuedDecoration == null) {
			queuedDecoration = decorationSegments[nextSegmentNum(rewind)];
			queuedDecoration.revive();

			if (rewind) {
				queuedDecoration.y = activeDecoration.y + activeDecoration.height;
			} else {
				queuedDecoration.y = activeDecoration.y - queuedDecoration.height;
			}
		}
	}

	private function nextSegmentNum(rewind:Bool):Int {
		if (rewind) {
			nextSegmentToLoad--;
		} else {
			nextSegmentToLoad++;
		}

		if (nextSegmentToLoad >= trackSegments.length) {
			nextSegmentToLoad -= trackSegments.length;
		}

		if (nextSegmentToLoad < 0) {
			nextSegmentToLoad += trackSegments.length;
		}

		return nextSegmentToLoad;
	}
}
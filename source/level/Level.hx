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
	public var bpm:Float = 0.0;
	public var pixelsPerBeat:Int = 0;

	public var nextSegmentToLoad = -1;

	public var levelSegments:Array<LevelSegment> = [];
	var endOfLevelSegments:Array<LevelSegment> = [];
	public var activeSegment:LevelSegment;
	public var queuedSegment:LevelSegment;

	public var background:FlxSprite;
	public var groundSpeed:Float = 4;

	public var lastRewind:Bool = false;
	public var rewind:Bool = false;

	var currentBeat:Int = 0;

	var segmentQueuedCallbacks:Array<Array<BeatEvent>->Void> = [];

	var endLevel = false;

	var level1Segments = [
		AssetPaths.segment00__json,
		AssetPaths.segment00__json,
		AssetPaths.segment07__json,
		AssetPaths.segment09__json,
		AssetPaths.segment08__json,
		AssetPaths.segment00__json,
		AssetPaths.segment01__json,
		AssetPaths.segment02__json,
		AssetPaths.segment11__json,
	];

	var level2Segments = [
		AssetPaths.segment00__json,
		AssetPaths.segment00__json,
		AssetPaths.segment05__json,
		AssetPaths.segment06__json,
		AssetPaths.segment08__json,
		AssetPaths.segment01__json,
		AssetPaths.segment03__json,
		AssetPaths.segment02__json,
		AssetPaths.segment03__json,
		AssetPaths.segment04__json,
		AssetPaths.segment08__json,
	];

	var level3Segments = [
		AssetPaths.segment00__json,
		AssetPaths.segment00__json,
		AssetPaths.segment08__json,
		AssetPaths.segment05__json,
		AssetPaths.segment06__json,
		AssetPaths.segment09__json,
		AssetPaths.segment01__json,
		AssetPaths.segment03__json,
		AssetPaths.segment11__json,
		AssetPaths.segment08__json,
		AssetPaths.segment07__json,
		AssetPaths.segment05__json,
		AssetPaths.segment06__json,
	];

	public function new(bpm:Float, pixelsPerBeat:Int) {
		this.bpm = bpm;
		this.pixelsPerBeat = pixelsPerBeat;

		background = new FlxSprite();
		background.loadGraphic(AssetPaths.nebula0__png, false, 560, 1260, true);
	}

	public function addBanners() {
		dispatchSegmentQueuedEvent([
			new BeatEvent(6, groundSpeed, new Ship(FlxG.width / 2, 0, 2)),
			new BeatEvent(7, groundSpeed, new Ship(FlxG.width / 2, 0, 3)),
			new BeatEvent(8, groundSpeed, new Ship(FlxG.width / 2, 0, 4))
		]);
	}

	public function addGoalBanner() {
		dispatchSegmentQueuedEvent([
			new BeatEvent(198, groundSpeed, new Ship(FlxG.width / 2, 0, 5)),
		]);
	}

	public function addSegmentQueuedListener(callbackFn:Array<BeatEvent>->Void) {
		segmentQueuedCallbacks.push(callbackFn);
	}

	public function initTestBeatEvents(laneCoords:Array<Float>) {
		var beatEvents:Array<BeatEvent> = [];
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
		dispatchSegmentQueuedEvent(beatEvents);
	}

	public function addToState(state:FlxState) {
		state.add(background);

		for (ls in levelSegments) {
			ls.addToState(state);
		}

		for (els in endOfLevelSegments) {
			els.addToState(state);
		}
	}

	public function loadOgmoMap(levelNum:Int) {
		var ogmoFile = AssetPaths.test__ogmo;
		var segments = getSegmentsForLevel(levelNum);
		for (s in segments) {
			var ls = new LevelSegment();
			ls.load(ogmoFile, s);
			levelSegments.push(ls);
		}

		var fiveLaneSegments = [
			AssetPaths.segment00__json,
			AssetPaths.segment00__json,
			AssetPaths.segment00__json,
		];
		for (fls in fiveLaneSegments) {
			var ls = new LevelSegment();
			ls.load(ogmoFile, fls);
			endOfLevelSegments.push(ls);
		}

		queueSegmentIfNeeded(rewind);
	}

	public function setBeat(value:Int) {
		currentBeat = value;
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

		if (queuedSegment != null) {
			queuedSegment.kill();
			queuedSegment = null;
		}

		nextSegmentToLoad = -1;
		lastRewind = rewind;
		queueSegmentIfNeeded(rewind);
	}

	public function queueEndOfLevel() {
		endLevel = true;
		levelSegments = endOfLevelSegments;
		nextSegmentToLoad = -1;
	}

	private function getSegmentsForLevel(levelNum:Int): Array<String> {
		if (levelNum == 1) {
			return level1Segments;
		}
		if (levelNum == 2) {
			return level2Segments;
		}
		if (levelNum == 3) {
			return level3Segments;
		}
		throw 'Unrecognized level: ${levelNum}. Valid levels are 1,2, or 3';
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
				if (!endLevel) {
					dispatchSegmentQueuedEvent(queuedSegment.generateBeatEvents(currentBeat, pixelsPerBeat));
				}
			}
		}
	}

	private function dispatchSegmentQueuedEvent(events:Array<BeatEvent>) {
		for (fn in segmentQueuedCallbacks) {
			fn(events);
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

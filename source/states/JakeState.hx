package states;

import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import events.BeatEvent;
import events.RenderEvent;
import entities.Ship;
import haxefmod.FmodEvents.FmodCallback;
import flixel.system.FlxAssets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import level.LevelIO;
import level.Level;

class JakeState extends FlxState
{
	// TODO: These wil likely live somewhere else ultimately
	var bpm = 112.0; // hardcode these for now, but we could ideally get them from FMOD (but not for this jam)
	var pixPerBeat = 100;
	var screenBeatSpaces = (FlxG.height / 100);
	var focusBeat = 5; // this is the beat where things align on screen (the one right in front of the player)

	var lastTick:Float = 0.0;
	var tickDiff:Float = 0.0;

	var currentBeat:Int = 0;

	var debugSpeaker:FlxSprite;

	var beatEvents:Array<BeatEvent> = [];
	var renderEvents:Map<Int, Array<BeatEvent>> = new Map();

	var beaters:Array<Ship> = [];
	var tweens:Array<FlxTween> = [];

	override public function create()
	{
		super.create();
		FmodManager.PlaySong(FmodSongs.LetsGo);
		FmodManager.RegisterCallbacksForSong(beat, FmodCallback.TIMELINE_BEAT);

		var level = LevelIO.loadFromJSON(AssetPaths.level_0__json);

		// Debug for testing purposes
		beatEvents.push(new BeatEvent(15, 0.5, new Ship(0, 0)));
		beatEvents.push(new BeatEvent(13, 1.0, new Ship(100, 0)));
		beatEvents.push(new BeatEvent(14, 1.0, new Ship(200, 0)));
		beatEvents.push(new BeatEvent(15, 1.0, new Ship(100, 0)));
		beatEvents.push(new BeatEvent(16, 1.0, new Ship(200, 0)));
		beatEvents.push(new BeatEvent(17, 1.0, new Ship(100, 0)));
		beatEvents.push(new BeatEvent(18, 1.0, new Ship(200, 0)));
		beatEvents.push(new BeatEvent(19, 1.0, new Ship(100, 0)));
		beatEvents.push(new BeatEvent(15, 2.0, new Ship(250, 0)));
		beatEvents.push(new BeatEvent(16, 3.0, new Ship(300, 0)));
		parse(beatEvents);

		var newLevel = new Level();
		newLevel.name = "New level who dis";
		newLevel.beatEvents = beatEvents;
		LevelIO.saveToJSON(AssetPaths.level_0__json, newLevel);

		debugSpeaker = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
		debugSpeaker.loadGraphic(AssetPaths.speakerTest__png, true, 80, 80);
		debugSpeaker.animation.add("sound", [1, 0], 10, false);
		debugSpeaker.animation.play("sound");
		add(debugSpeaker);

		#if !FLX_NO_DEBUG
		var y = 0;
		while (y < FlxG.height) {
			var divider = new FlxSprite(FlxG.width / 2, y, AssetPaths.divider__png);
			divider.scale.set(FlxG.width / divider.width, 1);
			add(divider);
			if (y == focusBeat * pixPerBeat) {
				divider.alpha = 1;
			} else {
				divider.alpha = 0.5;
			}
			y += pixPerBeat;
		}
		#end
	}

	private function parse(events:Array<BeatEvent>) {
		for (e in events) {
			// floor this so we make sure to render sooner rather than later
			var beginRenderBeat = Math.floor(1.0 * e.impactBeat - (focusBeat / e.speed));

			trace(e, " starting at ", beginRenderBeat);

			//              the impact y-coord  minus   how many beats on screen   times  how fast our ship moves
			e.sprite.y = (focusBeat * pixPerBeat) - (e.impactBeat - beginRenderBeat) * pixPerBeat * e.speed;
			e.sprite.startY = e.sprite.y;
			if (!renderEvents.exists(beginRenderBeat)) {
				renderEvents[beginRenderBeat] = new Array<BeatEvent>();
			}

			renderEvents[beginRenderBeat].push(e);
		}
	}


	private function beat() {
		debugSpeaker.animation.play("sound", true);
		currentBeat++;

		// cancel any in-progress tweens
		for (t in tweens) {
			if (!t.finished) {
				t.cancel();
			}
		}
		tweens.resize(0);

		if (renderEvents.exists(currentBeat)) {
			for (e in renderEvents[currentBeat]) {
				trace("adding {} on beat {}", e, currentBeat);
				add(e.sprite);
				beaters.push(e.sprite);
				e.sprite.speed = e.speed;
			}
		}

		for (ship in beaters) {
			ship.beat++;

			// set up tween to interpolate using our bpm to keep things aligned
			tweens.push(FlxTween.linearMotion(
				ship,
				ship.x,
				ship.y,
				ship.x,
				ship.startY + ship.beat * (ship.speed * pixPerBeat),
				60.0 / bpm)
			);
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FmodManager.Update();
	}

	 override public function onFocusLost():Void {
		 super.onFocusLost();
		 FmodManager.PauseSong();
	 }

	 override public function onFocus():Void {
		 super.onFocus();
		 FmodManager.UnpauseSong();
	 }
}

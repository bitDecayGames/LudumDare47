package states;

import flixel.util.FlxColor;
import events.BeatEvent;
import events.RenderEvent;
import entities.Ship;
import haxefmod.FmodEvents.FmodCallback;
import flixel.system.FlxAssets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class LoganState extends FlxState
{
	// TODO: These wil likely live somewhere else ultimately
	var pixPerBeat = 100;
	var screenBeatSpaces = (FlxG.height / 100);
	var focusBeat = 5; // this is the beat where things align on screen (the one right in front of the player)


	var currentBeat:Int = 0;

	var debugSpeaker:FlxSprite;

	var beatEvents:Array<BeatEvent> = [];
	var renderEvents:Map<Int, Array<BeatEvent>> = new Map();

	var beaters:Array<Ship> = [];

	override public function create()
	{
		super.create();
		FmodManager.PlaySong(FmodSongs.LetsGo);

		// Debug for testing purposes
		beatEvents.push(new BeatEvent(15, 0.5, new Ship(0, 0)));
		beatEvents.push(new BeatEvent(15, 1, new Ship(50, 0)));
		beatEvents.push(new BeatEvent(15, 2, new Ship(100, 0)));
		beatEvents.push(new BeatEvent(15, 3, new Ship(200, 0)));
		parse(beatEvents);

		debugSpeaker = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
		debugSpeaker.loadGraphic(AssetPaths.speakerTest__png, true, 80, 80);
		debugSpeaker.animation.add("sound", [1, 0], 10, false);
		debugSpeaker.animation.play("sound");
		add(debugSpeaker);

		FmodManager.RegisterCallbacksForSong(beat, FmodCallback.TIMELINE_BEAT);

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
	}

	private function parse(events:Array<BeatEvent>) {
		for (e in events) {
			// floor this so we make sure to render sooner rather than later
			var beginRenderBeat = Math.floor(1.0 * e.impactBeat - (focusBeat / e.speed));

			trace(e, " starting at ", beginRenderBeat);

			//              the impact y-coord          how many beats on screen
			e.sprite.y = (focusBeat * pixPerBeat) - (e.impactBeat - beginRenderBeat) * pixPerBeat * e.speed;
			if (!renderEvents.exists(beginRenderBeat)) {
				renderEvents[beginRenderBeat] = new Array<BeatEvent>();
			}

			renderEvents[beginRenderBeat].push(e);
		}
	}

	private function beat() {
		debugSpeaker.animation.play("sound", true);
		currentBeat++;
		trace("currentBeat", currentBeat);
		if (currentBeat == 15) {
			trace("things should align");
		}

		for (ship in beaters) {
			ship.y += ship.speed * pixPerBeat;
		}

		if (renderEvents.exists(currentBeat)) {
			for (e in renderEvents[currentBeat]) {
				trace("adding {} on beat {}", e, currentBeat);
				add(e.sprite);
				beaters.push(e.sprite);
				e.sprite.speed = e.speed;
			}
		}
	}

	var time:Float = 0.0;

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

package states;

import entities.BeatEvent;
import entities.RenderEvent;
import haxefmod.FmodEvents.FmodCallback;
import flixel.system.FlxAssets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class LoganState extends FlxState
{
	var currentBeat:Int = 0;

	var debugSpeaker:FlxSprite;

	var beatEvents:Array<BeatEvent> = [];
	var renderEvents:Map<Int, Array<RenderEvent>> = new Map();

	override public function create()
	{
		super.create();
		FmodManager.PlaySong(FmodSongs.LetsGo);

		// Debug for testing purposes
		beatEvents.push(new BeatEvent(10, 1, new FlxSprite(0, 0, AssetPaths.debugShip__png)));
		beatEvents.push(new BeatEvent(12, 1, new FlxSprite(50, 0, AssetPaths.debugShip__png)));
		beatEvents.push(new BeatEvent(15, 1.2, new FlxSprite(100, 0, AssetPaths.debugShip__png)));
		beatEvents.push(new BeatEvent(30, 3, new FlxSprite(200, 0, AssetPaths.debugShip__png)));
		parse(beatEvents);

		debugSpeaker = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
		debugSpeaker.loadGraphic(AssetPaths.speakerTest__png, true, 80, 80);
		debugSpeaker.animation.add("sound", [1, 0], 10, false);
		debugSpeaker.animation.play("sound");
		add(debugSpeaker);

		FmodManager.RegisterCallbacksForSong(beat, FmodCallback.TIMELINE_BEAT);
	}

	private function parse(events:Array<BeatEvent>) {
		var pixPerBeat = 100;
		var screenSpace = (FlxG.height / pixPerBeat);

		for (e in events) {
			// floor this so we make sure to render sooner rather than later
			var beginRenderBeat = Math.floor(1.0 * e.impactBeat - (screenSpace / e.speed));
			if (!renderEvents.exists(beginRenderBeat)) {
				renderEvents[beginRenderBeat] = new Array<RenderEvent>();
			}

			renderEvents[beginRenderBeat].push(new RenderEvent(beginRenderBeat, e.sprite));
		}
	}

	private function beat() {
		debugSpeaker.animation.play("sound", true);
		currentBeat++;
		trace("currentBeat", currentBeat);
		if (renderEvents.exists(currentBeat)) {
			for (e in renderEvents[currentBeat]) {
				trace("adding {} on beat {}", e, currentBeat);
				add(e.sprite);
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

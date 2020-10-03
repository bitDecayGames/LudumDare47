package states;

import haxefmod.FmodEvents.FmodCallback;
import flixel.system.FlxAssets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class LoganState extends FlxState
{

	var debugSpeaker:FlxSprite;

	override public function create()
	{
		super.create();

		FmodManager.PlaySong(FmodSongs.LetsGo);

		debugSpeaker = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
		debugSpeaker.loadGraphic(AssetPaths.speakerTest__png, true, 80, 80);
		debugSpeaker.animation.add("sound", [1, 0], 10, false);
		debugSpeaker.animation.play("sound");
		add(debugSpeaker);

		FmodManager.RegisterCallbacksForSong(beat, FmodCallback.TIMELINE_BEAT);
	}

	private function beat() {
		debugSpeaker.animation.play("sound", true);
	}

	var time:Float = 0.0;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FmodManager.Update();
	}
}

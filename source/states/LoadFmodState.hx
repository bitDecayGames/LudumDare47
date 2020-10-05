package states;

import states.Playstate2.PlayState2;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.system.scaleModes.FillScaleMode;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxState;

/**
 * @author Tanner Moore
 * For games that are deployed to html5, the FMOD audio engine must be loaded before starting the game.
 */
class LoadFmodState extends FlxState {
	override public function create():Void {
		FlxG.scaleMode = new RatioScaleMode();
		FmodManager.Initialize();

		var loadingText = new FlxText(0, 0, "Loading...");
		loadingText.setFormat(null, 20, FlxColor.WHITE, FlxTextAlign.CENTER, NONE, FlxColor.BLACK);
		loadingText.x = (FlxG.width / 2) - loadingText.width / 2;
		loadingText.y = (FlxG.height / 2) - loadingText.height / 2;
		add(loadingText);
	}

	override public function update(elapsed:Float):Void {
		if (FmodManager.IsInitialized()) {
			#if logan
			FlxG.switchState(new PlayState());
			#elseif tristan
			FlxG.switchState(new SplashScreenState());
			#elseif tanner
			FlxG.switchState(new PlayState2());
			#elseif mike
			FlxG.switchState(new MikeState());
			#else
			FlxG.switchState(new SplashScreenState());
			#end
		}
	}
}

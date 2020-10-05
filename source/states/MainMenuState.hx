package states;

import flixel.FlxSprite;
import com.bitdecay.analytics.Bitlytics;
import haxefmod.flixel.FmodFlxUtilities;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import helpers.UiHelpers;
import lime.system.System;

class MainMenuState extends FlxUIState {
    var _btnPlay:FlxButton;
    var _btnCredits:FlxButton;
    var _btnExit:FlxButton;

    override public function create():Void {
        super.create();
        FmodManager.PlaySong(FmodSongs.LetsGo);
        FlxG.log.notice("loaded scene");
        bgColor = FlxColor.TRANSPARENT;

        var bgImage = new FlxSprite(AssetPaths.titleSplash__png);
        bgImage.width = FlxG.width;
        bgImage.height = FlxG.height;
        add(bgImage);

        _btnPlay = UiHelpers.CreateMenuButton("Play", clickPlay);
        _btnPlay.setPosition(FlxG.width/2 - _btnPlay.width/2, FlxG.height - _btnPlay.height - 80);
        _btnPlay.updateHitbox();
        add(_btnPlay);

        _btnCredits = UiHelpers.CreateMenuButton("Credits", clickCredits);
        _btnCredits.setPosition(FlxG.width/2 - _btnCredits.width/2, FlxG.height - _btnCredits.height - 50);
        _btnCredits.updateHitbox();
        add(_btnCredits);

        #if windows
        _btnExit = UiHelpers.CreateMenuButton("Exit", clickExit);
        _btnExit.setPosition(FlxG.width/2 - _btnExit.width/2, FlxG.height - _btnExit.height - 20);
        _btnExit.updateHitbox();
        add(_btnExit);
        #end
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        FmodManager.Update();
    }

    function clickPlay():Void {
        FmodFlxUtilities.TransitionToStateAndStopMusic(new PlayState());
    }

    function clickCredits():Void {
        FmodFlxUtilities.TransitionToState(new CreditsState());
    }

    #if windows
    function clickExit():Void {
        System.exit(0);
    }
    #end

    override public function onFocusLost():Void {
		super.onFocusLost();
        FmodManager.PauseSong();
        Bitlytics.Instance().Pause();
	}

	override public function onFocus():Void {
		super.onFocus();
		FmodManager.UnpauseSong();
        Bitlytics.Instance().Resume();
	}
}
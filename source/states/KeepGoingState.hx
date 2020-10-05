package states;

import haxefmod.flixel.FmodFlxUtilities;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import helpers.UiHelpers;
import lime.system.System;

class KeepGoingState extends FlxUIState {

    var _txtDontGiveUp:FlxText;
    var _txtPressSpace:FlxText;

    var _showRetryText:Bool = false;

    override public function create():Void {
        super.create();
        FmodManager.PlaySong(FmodSongs.LetsGo);
        FlxG.log.notice("loaded scene");
        bgColor = FlxColor.TRANSPARENT;

        _txtDontGiveUp = new FlxText();
        _txtDontGiveUp.setPosition(FlxG.width/2, FlxG.height/4);
        _txtDontGiveUp.size = 30;
        _txtDontGiveUp.alignment = FlxTextAlign.CENTER;
        _txtDontGiveUp.text = "Don't give up!";

        add(_txtDontGiveUp);

        _txtPressSpace = new FlxText();
        _txtPressSpace.setPosition(FlxG.width/2, FlxG.height/3);
        _txtPressSpace.size = 20;
        _txtPressSpace.alignment = FlxTextAlign.CENTER;
        _txtPressSpace.text = "Press Spacebar to continue";

        add(_txtPressSpace);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        FmodManager.Update();

        _txtDontGiveUp.x = FlxG.width/2 - _txtDontGiveUp.width/2;
        _txtPressSpace.x = FlxG.width/2 - _txtPressSpace.width/2;

        if (FlxG.keys.justPressed.O) {
            _showRetryText = !_showRetryText;
        }

        if (_showRetryText) {
            _txtDontGiveUp.visible = true;
            _txtPressSpace.visible = true;
        } else {
            _txtDontGiveUp.visible = false;
            _txtPressSpace.visible = false;
        }
    }
}
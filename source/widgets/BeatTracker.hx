package widgets;

import flixel.FlxState;
import haxefmod.FmodEvents.FmodCallback;
import haxe.Timer;
import flixel.tweens.FlxTween;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil;
import haxefmod.flixel.FmodFlxUtilities;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import helpers.UiHelpers;
import lime.system.System;

class BeatTracker {
    var parentState:FlxState;
    var verticalPositionOnScreen:Int;
    var bpm:Int;

    var _staticSprite:FlxSprite;
    var _scale:FlxPoint;
    var _beatIndicatorSpeed:Float;

    public function new(parentState:FlxState, bpm:Int, verticalPositionOnScreen:Int) {
        this.parentState = parentState;
        this.bpm = bpm;
        this.verticalPositionOnScreen = verticalPositionOnScreen;

        _staticSprite = new FlxSprite();
        _staticSprite.makeGraphic(2, 40, FlxColor.WHITE);
        _staticSprite.setPosition(FlxG.width/2 - _staticSprite.width/2, verticalPositionOnScreen - _staticSprite.height/2);
        parentState.add(_staticSprite);

        _beatIndicatorSpeed = (60/bpm)*2;
    }

    public function SpawnLines() {
        var leftLine = new FlxSprite();
        leftLine.makeGraphic(2, 40, FlxColor.WHITE);
        leftLine.setPosition(0, verticalPositionOnScreen - leftLine.height/2);
        var leftLineTween = FlxTween.linearMotion(
            leftLine,
            leftLine.x,
            leftLine.y,
            FlxG.width/2,
            leftLine.y,
            _beatIndicatorSpeed);
            parentState.add(leftLine);
        leftLineTween.onComplete = (t)->{
            parentState.remove(leftLine);
        }
        
        var rightLine = new FlxSprite();
        rightLine.makeGraphic(2, 40, FlxColor.WHITE);
        rightLine.setPosition(FlxG.width, verticalPositionOnScreen - rightLine.height/2);
        var rightLineTween = FlxTween.linearMotion(
            rightLine,
            rightLine.x,
            rightLine.y,
            FlxG.width/2,
            rightLine.y,
            _beatIndicatorSpeed);
            parentState.add(rightLine);
        rightLineTween.onComplete = (t)->{
            parentState.remove(rightLine);
        }
    }
}
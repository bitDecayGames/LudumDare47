package actions;

import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalIFlxInput;
import flixel.FlxObject;
import flixel.input.FlxSwipe;
import flixel.input.keyboard.FlxKey;
import flixel.input.actions.FlxAction.FlxActionDigital;

class Actions {

	private static inline var swipeMinDist:Float = 15;

	public var up = new FlxActionDigital();
	public var down = new FlxActionDigital();
	public var left = new FlxActionDigital();
	public var right = new FlxActionDigital();

	public function new() {
		up.addKey(FlxKey.W, JUST_PRESSED);
		up.addKey(FlxKey.UP, JUST_PRESSED);
		up.add(new SwipeInputDigital(FlxObject.UP, swipeMinDist));
		up.addGamepad(DPAD_UP, JUST_PRESSED);

		down.addKey(FlxKey.S, JUST_PRESSED);
		down.addKey(FlxKey.DOWN, JUST_PRESSED);
		down.add(new SwipeInputDigital(FlxObject.DOWN, swipeMinDist));
		down.addGamepad(DPAD_DOWN, JUST_PRESSED);

		left.addKey(FlxKey.A, JUST_PRESSED);
		left.addKey(FlxKey.LEFT, JUST_PRESSED);
		left.add(new SwipeInputDigital(FlxObject.LEFT, swipeMinDist));
		left.addGamepad(DPAD_LEFT, JUST_PRESSED);

		right.addKey(FlxKey.D, JUST_PRESSED);
		right.addKey(FlxKey.RIGHT, JUST_PRESSED);
		right.add(new SwipeInputDigital(FlxObject.RIGHT, swipeMinDist));
		right.addGamepad(DPAD_RIGHT, JUST_PRESSED);
	}
}
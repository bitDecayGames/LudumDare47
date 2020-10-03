package actions;

import flixel.input.keyboard.FlxKey;
import flixel.input.actions.FlxAction.FlxActionDigital;

class Actions {

	public var up = new FlxActionDigital();
	public var down = new FlxActionDigital();
	public var left = new FlxActionDigital();
	public var right = new FlxActionDigital();

	public function new() {
		up.addKey(FlxKey.W, JUST_PRESSED);
		up.addKey(FlxKey.UP, JUST_PRESSED);
		up.addGamepad(DPAD_UP, JUST_PRESSED);

		down.addKey(FlxKey.S, JUST_PRESSED);
		down.addKey(FlxKey.DOWN, JUST_PRESSED);
		down.addGamepad(DPAD_DOWN, JUST_PRESSED);

		left.addKey(FlxKey.A, JUST_PRESSED);
		left.addKey(FlxKey.LEFT, JUST_PRESSED);
		left.addGamepad(DPAD_LEFT, JUST_PRESSED);

		right.addKey(FlxKey.D, JUST_PRESSED);
		right.addKey(FlxKey.RIGHT, JUST_PRESSED);
		right.addGamepad(DPAD_RIGHT, JUST_PRESSED);
	}
}
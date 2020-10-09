package actions;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.input.actions.FlxAction;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxActionInput.FlxInputDevice;
import flixel.input.actions.FlxActionInputDigital;

class SwipeInputDigital extends FlxActionInputDigital {

	var swipeDir:Int;
	var min:Float = -1;
	var max:Float = -1;

	var minDistance:Float = 0;

	 public function new(dir:Int, minDistance:Float)
	{
		super(FlxInputDevice.OTHER, 0, FlxInputState.JUST_PRESSED);
		swipeDir = dir;

		this.minDistance = minDistance;

		switch (swipeDir) {
			case FlxObject.UP:
				min = 315;
				max = 45;
			case FlxObject.DOWN:
				min = 135;
				max = 225;
			case FlxObject.LEFT:
				min = 225;
				max = 315;
			case FlxObject.RIGHT:
				min = 45;
				max = 135;
		}
	}

		override public function check(Action:FlxAction):Bool
		{
			return switch (trigger) {
				case PRESSED: false;
				case RELEASED: false;
				case JUST_PRESSED:
					for (swipe in FlxG.swipes) {
						if (swipe.distance < minDistance) {
							continue;
						}

						if (inRange(swipe.angle, min, max)) {
							return true;
						}
					}
					return false;
				case JUST_RELEASED: false;
				default: false;
			}


			return false;
		}

		private function normalize(angle:Float):Float {
			while (angle < 0) {
				angle += 360;
			}

			while (angle > 360) {
				angle -= 360;
			}

			return angle;
		}

		private function inRange(val:Float, min:Float, max:Float):Bool {
			val = normalize(val);
			if (max - min > 0) {
				// not crossing the zero line
				return val > min && val <= max;
			} else {
				// crosses the zero line
				return val > min || val <= max;
			}
		}
	}
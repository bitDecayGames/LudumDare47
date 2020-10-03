package states;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.FlxG;
import entities.Ship;
import haxefmod.FmodEvents.FmodCallback;
import flixel.FlxState;
import actions.Actions;

using extensions.FlxObjectExt;

class LoganPlayerState extends FlxState {

	var bufferMS:Float = 200; // pre is easy...

	var postBufferMS:Float = 100; // post is a little harder as it has to act after the beat

	var actions:Actions;
	var inputBuffer:Map<FlxActionDigital, Float> = new Map();

	var player:Ship;
	var playerLane:Int = 0;

	var laneCoords:Array<Float> = [
		FlxG.width / 2 - 160,
		FlxG.width / 2 - 80,
		FlxG.width / 2,
		FlxG.width / 2 + 80,
		FlxG.width / 2 + 160
	];

	var debugSpeaker:FlxSprite;

	override public function create()
	{
		super.create();
		FmodManager.PlaySong(FmodSongs.LetsGo);
		FmodManager.RegisterCallbacksForSong(beat, FmodCallback.TIMELINE_BEAT);

		actions = new Actions();

		player = new Ship(0, 0);
		alignPlayerToLane();
		add(player);

		debugSpeaker = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
		debugSpeaker.loadGraphic(AssetPaths.speakerTest__png, true, 80, 80);
		debugSpeaker.animation.add("sound", [1, 0], 10, false);
		debugSpeaker.animation.play("sound");
		add(debugSpeaker);
	}

	private function beat() {
		debugSpeaker.animation.play("sound", true);

		haxe.Timer.delay(checkInput, Std.int(200));
		// checkInput();
	}

	private function checkInput() {
		var timestamp = Date.now().getTime();

		if (inputBuffer.exists(actions.left)) {
			if (timestamp - inputBuffer[actions.left] < bufferMS) {
				playerLane--;
				player.color = FlxColor.GREEN;
			} else {
				player.color = FlxColor.RED;
			}
		}

		if (inputBuffer.exists(actions.right)) {
			if (timestamp - inputBuffer[actions.right] < bufferMS) {
				playerLane++;
				player.color = FlxColor.GREEN;
			} else {
				player.color = FlxColor.RED;
			}
		}

		inputBuffer.clear();

		alignPlayerToLane();
	}

	private function alignPlayerToLane() {
		player.setMidpoint(laneCoords[playerLane], FlxG.height - 50);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		var timestamp = Date.now().getTime();
		FmodManager.Update();

		if (actions.left.check() && !inputBuffer.exists(actions.left)) {
			inputBuffer[actions.left] = timestamp;
			player.color = FlxColor.BLUE;
		}

		if (actions.right.check() && !inputBuffer.exists(actions.right)) {
			inputBuffer[actions.right] = timestamp;
			player.color = FlxColor.BLUE;
		}

		if (actions.up.check() && !inputBuffer.exists(actions.up)) {
			inputBuffer[actions.up] = timestamp;
			player.color = FlxColor.BLUE;
		}

		if (actions.down.check() && !inputBuffer.exists(actions.down)) {
			inputBuffer[actions.down] = timestamp;
			player.color = FlxColor.BLUE;
		}
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
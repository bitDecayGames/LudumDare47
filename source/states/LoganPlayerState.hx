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

	// milliseconds the player can be early
	var bufferMS:Float = 100;

	// milliseconds the player can be late
	var postBufferMS:Float = 100;

	var actions:Actions;
	var inputBuffer:Map<FlxActionDigital, Float> = new Map();

	var beatTime:Float;
	var beatAwaitingProcessing:Bool;

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
		FmodManager.PlaySong(FmodSongs.Song2);
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
		beatTime = Date.now().getTime();
		beatAwaitingProcessing = true;
	}

	private function checkInput(timestamp:Float):Bool {
		if (inputBuffer.exists(actions.left)) {
			if (timestamp - inputBuffer[actions.left] < bufferMS) {
				playerLane--;
				player.color = FlxColor.GREEN;
			} else {
				player.color = FlxColor.RED;
			}
			resetBeatVars();
		}

		if (inputBuffer.exists(actions.right)) {
			if (timestamp - inputBuffer[actions.right] < bufferMS) {
				playerLane++;
				player.color = FlxColor.GREEN;
			} else {
				player.color = FlxColor.RED;
			}
			resetBeatVars();
		}

		// return false if still awaiting processing
		return !beatAwaitingProcessing;
	}

	private function resetBeatVars() {
		inputBuffer.clear();
		alignPlayerToLane();
		beatAwaitingProcessing = false;
	}

	private function alignPlayerToLane() {
		player.setMidpoint(laneCoords[playerLane], FlxG.height - 50);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		var timestamp = Date.now().getTime();
		FmodManager.Update();

		if (beatAwaitingProcessing) {
			if (checkInput(beatTime)) {
				// input was handled, just bail
				return;
			}

			if (actions.left.check()) {
				playerLane--;
				player.color = FlxColor.YELLOW;
				beatAwaitingProcessing = false;
				resetBeatVars();
			}

			if (actions.right.check()) {
				playerLane++;
				player.color = FlxColor.YELLOW;
				beatAwaitingProcessing = false;
				resetBeatVars();
			}

			if (beatAwaitingProcessing && timestamp - beatTime > postBufferMS) {
				// hasn't processed beat yet, AND it's been past the buffer
				// count is as missed and move on
				resetBeatVars();
			}
		} else {
			if (actions.left.check() && !inputBuffer.exists(actions.left)) {
				inputBuffer[actions.left] = timestamp;
				player.color = FlxColor.BLUE;
			}

			if (actions.right.check() && !inputBuffer.exists(actions.right)) {
				inputBuffer[actions.right] = timestamp;
				player.color = FlxColor.BLUE;
			}
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
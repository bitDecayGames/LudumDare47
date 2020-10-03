package states;

import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.FlxG;
import entities.Ship;
import haxefmod.FmodEvents.FmodCallback;
import flixel.FlxState;
import actions.Actions;
import events.BeatEvent;
import events.RenderEvent;
import flixel.system.FlxAssets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

using extensions.FlxObjectExt;

class JakeState extends FlxState {

	// TODO: These wil likely live somewhere else ultimately
	var bpm = 112.0; // hardcode these for now, but we could ideally get them from FMOD (but not for this jam)
	var pixPerBeat = 100;
	var screenBeatSpaces = (FlxG.height / 100);
	var focusBeat = 5; // this is the beat where things align on screen (the one right in front of the player)

	var lastTick:Float = 0.0;
	var tickDiff:Float = 0.0;

	var currentBeat:Int = 0;

	var beatEvents:Array<BeatEvent> = [];
	var renderEvents:Map<Int, Array<BeatEvent>> = new Map();

	var beaters:FlxTypedGroup<Ship> = new FlxTypedGroup<Ship>();
	var tweens:Array<FlxTween> = [];

	// milliseconds the player can be early
	var bufferMS:Float = 100;

	// milliseconds the player can be late
	var postBufferMS:Float = 100;

	var actions:Actions;
	var inputBuffer:Map<FlxActionDigital, Float> = new Map();

	var beatTime:Float;
	var beatAwaitingProcessing:Bool;

	var player:Ship;
	var playerGroup:FlxTypedGroup<Ship> = new FlxTypedGroup<Ship>();
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
		FlxG.debugger.visible = true;
		FmodManager.PlaySong(FmodSongs.LetsGo);
		FmodManager.RegisterCallbacksForSong(beat, FmodCallback.TIMELINE_BEAT);

		// Debug for testing purposes
		for (i in 0...100) {
			var ship = new Ship(laneCoords[i % 5], 0);
			beatEvents.push(new BeatEvent(i * i, i * 0.1, ship));
		}
		parse(beatEvents);
		add(beaters);

		actions = new Actions();

		player = new Ship(0, 0);
		alignPlayerToLane();
		playerGroup.add(player);
		add(playerGroup);

		debugSpeaker = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
		debugSpeaker.loadGraphic(AssetPaths.speakerTest__png, true, 80, 80);
		debugSpeaker.animation.add("sound", [1, 0], 10, false);
		debugSpeaker.animation.play("sound");
		add(debugSpeaker);
	}

	private function parse(events:Array<BeatEvent>) {
		for (e in events) {
			// floor this so we make sure to render sooner rather than later
			var beginRenderBeat = Math.floor(1.0 * e.impactBeat - (focusBeat / e.speed));

			trace(e, " starting at ", beginRenderBeat);

			//              the impact y-coord  minus   how many beats on screen   times  how fast our ship moves
			e.sprite.y = (focusBeat * pixPerBeat) - (e.impactBeat - beginRenderBeat) * pixPerBeat * e.speed;
			// we want things to be lined up based on the bottom of the ship
			e.sprite.y -= e.sprite.height;
			e.sprite.startY = e.sprite.y;
			if (!renderEvents.exists(beginRenderBeat)) {
				renderEvents[beginRenderBeat] = new Array<BeatEvent>();
			}

			renderEvents[beginRenderBeat].push(e);
		}
	}

	private function beat() {
		debugSpeaker.animation.play("sound", true);
		beatTime = Date.now().getTime();
		beatAwaitingProcessing = true;

		currentBeat++;

		// cancel any in-progress tweens
		for (t in tweens) {
			if (!t.finished) {
				t.cancel();
			}
		}
		tweens.resize(0);

		if (renderEvents.exists(currentBeat)) {
			for (e in renderEvents[currentBeat]) {
				trace("adding {} on beat {}", e, currentBeat);
				beaters.add(e.sprite);
				e.sprite.speed = e.speed;
			}
		}

		for (ship in beaters) {
			ship.beat++;

			// set up tween to interpolate using our bpm to keep things aligned
			tweens.push(FlxTween.linearMotion(
				ship,
				ship.x,
				ship.y,
				ship.x,
				ship.startY + ship.beat * (ship.speed * pixPerBeat),
				60.0 / bpm)
			);
		}
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

	private function handlePlayerCarOverlap(player: Ship, ai: Ship) {
		beaters.remove(ai);
		ai.kill();
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

		FlxG.overlap(playerGroup, beaters, handlePlayerCarOverlap);
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
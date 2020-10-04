package states;

import flixel.text.FlxText;
import com.bitdecay.textpop.TextPop;
import flixel.tweens.motion.LinearMotion;
import flixel.tweens.misc.VarTween;
import haxe.Timer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.FlxG;
import entities.Ship;
import entities.Player;
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
import level.Ground;
import entities.BeatSpeaker;

using extensions.FlxObjectExt;

class PlayState extends FlxState {

	// TODO: These wil likely live somewhere else ultimately
	var bpm = 130.0; // hardcode these for now, but we could ideally get them from FMOD (but not for this jam)
	var pixPerBeat = 100;
	var screenBeatSpaces = (FlxG.height / 100);
	var focusBeat = 5; // this is the beat where things align on screen (the one right in front of the player)

	var comboText:FlxText;
	var comboCounter:Int = 0;

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

	var timePerBeat:Float = 0;
	var halfTime:Float = 0;

	var actions:Actions;
	var inputBuffer:Map<FlxActionDigital, Float> = new Map();

	var beatTime:Float;
	var beatAwaitingProcessing:Bool;

	var player:Player;
	var playerTween:LinearMotion = null;
	var playerGroup:FlxTypedGroup<Player> = new FlxTypedGroup<Player>();
	var playerLane:Int = 2;
	var targetPlayerLane:Int = 2;
	var lastPlayerInput:Float = -1;

	var laneCoords:Array<Float> = [
		FlxG.width / 2 - 160,
		FlxG.width / 2 - 80,
		FlxG.width / 2,
		FlxG.width / 2 + 80,
		FlxG.width / 2 + 160
	];

	var beatSpeaker:BeatSpeaker;

	var ground: Ground = new Ground();

	override public function create()
	{
		super.create();

		comboText = new FlxText(10, FlxG.height-45, 100, "0", 30);
		add(comboText);

		timePerBeat = 60.0/bpm;
		halfTime = timePerBeat/2;
		trace("timePerBeat: " + timePerBeat);
		trace("halfTime: " + halfTime);

		FlxG.debugger.visible = true;
		FmodManager.PlaySong(FmodSongs.Level1);
		FmodManager.RegisterCallbacksForSong(beat, FmodCallback.TIMELINE_BEAT);

		add(ground);

		#if !FLX_NO_DEBUG
		var y = 0;
		while (y < FlxG.height) {
			var divider = new FlxSprite(FlxG.width / 2, y, AssetPaths.divider__png);
			divider.scale.set(FlxG.width / divider.width, 1);
			add(divider);
			if (y == focusBeat * pixPerBeat) {
				divider.alpha = 1;
			} else {
				divider.alpha = 0.5;
			}
			y += pixPerBeat;
		}
		#end

		// Debug for testing purposes
		// for (i in 0...100) {
		// 	var ship = new Ship(laneCoords[i % 5], 0, false);
		// 	beatEvents.push(new BeatEvent(i * i, i * 0.1, ship));
		// }

		beatEvents.push(new BeatEvent(10, 1, new Ship(laneCoords[0], 0)));
		beatEvents.push(new BeatEvent(10, 1, new Ship(laneCoords[1], 0)));
		beatEvents.push(new BeatEvent(10, 1, new Ship(laneCoords[3], 0)));
		beatEvents.push(new BeatEvent(10, 1, new Ship(laneCoords[4], 0)));

		beatEvents.push(new BeatEvent(14, 1, new Ship(laneCoords[2], 0)));

		beatEvents.push(new BeatEvent(20, 1, new Ship(laneCoords[1], 0)));
		beatEvents.push(new BeatEvent(20, 1, new Ship(laneCoords[2], 0)));
		beatEvents.push(new BeatEvent(20, 1, new Ship(laneCoords[3], 0)));
		beatEvents.push(new BeatEvent(20, 1, new Ship(laneCoords[4], 0)));

		beatEvents.push(new BeatEvent(24, 1, new Ship(laneCoords[0], 0)));
		beatEvents.push(new BeatEvent(25, 1, new Ship(laneCoords[1], 0)));
		beatEvents.push(new BeatEvent(26, 1, new Ship(laneCoords[2], 0)));
		beatEvents.push(new BeatEvent(27, 1, new Ship(laneCoords[3], 0)));

		beatEvents.push(new BeatEvent(33, 1, new Ship(laneCoords[4], 0)));
		beatEvents.push(new BeatEvent(34, 1, new Ship(laneCoords[3], 0)));
		beatEvents.push(new BeatEvent(35, 1, new Ship(laneCoords[2], 0)));
		beatEvents.push(new BeatEvent(36, 1, new Ship(laneCoords[1], 0)));

		beatEvents.push(new BeatEvent(45, 1, new Ship(laneCoords[0], 0)));
		beatEvents.push(new BeatEvent(45, 1, new Ship(laneCoords[1], 0)));
		beatEvents.push(new BeatEvent(45, 1, new Ship(laneCoords[3], 0)));
		beatEvents.push(new BeatEvent(45, 1, new Ship(laneCoords[4], 0)));

		beatEvents.push(new BeatEvent(47, 1, new Ship(laneCoords[1], 0)));
		beatEvents.push(new BeatEvent(47, 1, new Ship(laneCoords[3], 0)));

		beatEvents.push(new BeatEvent(49, 1, new Ship(laneCoords[1], 0)));
		beatEvents.push(new BeatEvent(49, 1, new Ship(laneCoords[3], 0)));

		beatEvents.push(new BeatEvent(53, 2, new Ship(laneCoords[2], 0)));

		beatEvents.push(new BeatEvent(55, 1, new Ship(laneCoords[0], 0)));
		beatEvents.push(new BeatEvent(55, 1, new Ship(laneCoords[1], 0)));
		beatEvents.push(new BeatEvent(55, 1, new Ship(laneCoords[3], 0)));
		beatEvents.push(new BeatEvent(55, 1, new Ship(laneCoords[4], 0)));

		parse(beatEvents);

		add(beaters);

		actions = new Actions();

		player = new Player(0, 0);
		player.x = laneCoords[playerLane] - player.width/2;
		player.y = (focusBeat * pixPerBeat) + 30;

		playerGroup.add(player);
		add(playerGroup);

		beatSpeaker = new BeatSpeaker();
		add(beatSpeaker);
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
		beatSpeaker.handleBeat();
		beatTime = Date.now().getTime();
		beatAwaitingProcessing = true;

		FlxG.camera.shake(0.005, 0.05);
		FlxG.camera.flash(0x22FFFFFF, 0.3);

		currentBeat++;

		// cancel any in-progress tweens
		for (t in tweens) {
			if (!t.finished) {
				t.cancelChain();
			}
		}
		tweens.resize(0);

		if (renderEvents.exists(currentBeat)) {
			for (e in renderEvents[currentBeat]) {
				trace("adding {} on beat {}", e, currentBeat);
				beaters.add(e.sprite);
				add(e.sprite);
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

		ground.handleBeat();
	}

	private function resetBeatVars() {
		if (playerTween == null || playerTween.finished) {
			alignPlayerToLane();
		}
	}

	private function alignPlayerToLane() {
		var newPlayerLane = Std.int(Math.max(0, Math.min(laneCoords.length-1, targetPlayerLane)));
		if (newPlayerLane != playerLane) {
			playerLane = newPlayerLane;
			playerTween = FlxTween.linearMotion(
				player,
				player.x,
				player.y,
				laneCoords[playerLane] - player.width/2,
				player.y,
				timePerBeat / 2
				);
		}
	}

	private function handlePlayerCarOverlap(player: Ship, ai: Ship) {
		beaters.remove(ai);
		ai.kill();
		resetCombo();
		TextPop.pop(Std.int(player.x), Std.int(player.y), "Collision", null, 25);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		var timestamp = Date.now().getTime();
		FmodManager.Update();

		if (playerTween == null || playerTween.finished) {
			if (actions.left.check()) {
				targetPlayerLane = playerLane - 1;
				alignPlayerToLane();
				calculateBeatScore(timestamp);
			}

			if (actions.right.check()) {
				targetPlayerLane = playerLane + 1;
				alignPlayerToLane();
				calculateBeatScore(timestamp);
			}
		}

		FlxG.overlap(playerGroup, beaters, handlePlayerCarOverlap);
		comboText.text = Std.string(comboCounter);
	}

	private function calculateBeatScore(ts:Float) {
		var diff = Math.abs(ts - beatTime) / 1000;
		trace("RawDiff: " + diff);
		if (diff > halfTime) {
			diff = Math.abs(diff - timePerBeat);
		}

		trace("Diff: " + diff);

		if (diff < timePerBeat / 4) {
			TextPop.pop(Std.int(player.x), Std.int(player.y), "Great!", null, 25);
			comboCounter++;
			player.color = FlxColor.BLUE;
		} else if (diff < timePerBeat / 3) {
			TextPop.pop(Std.int(player.x), Std.int(player.y), "Miss", null, 25);
			resetCombo();
			player.color = FlxColor.YELLOW;
		} else {
			TextPop.pop(Std.int(player.x), Std.int(player.y), "Miss", null, 25);
			resetCombo();
			player.color = FlxColor.RED;
		}
	}

	private function resetCombo() {
		comboCounter = 0;
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
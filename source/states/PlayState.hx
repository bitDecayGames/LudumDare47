package states;

import widgets.BeatTracker;
import flixel.FlxObject;
import openfl.filters.BitmapFilter;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.filters.ShaderFilter;
import shaders.Vhs;
import entities.ParentedSprite;
import com.bitdecay.textpop.style.builtin.FloatAway;
import com.bitdecay.textpop.style.Style;
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
import level.Level;
import entities.BeatSpeaker;
import textpop.FlyBack;
import openfl.filters.BlurFilter;

using extensions.FlxObjectExt;

class PlayState extends FlxState {

	// TODO: These wil likely live somewhere else ultimately
	var defaultBpm = 130.0; // hardcode these for now, but we could ideally get them from FMOD (but not for this jam)
	var defaultPixPerBeat = 100;

	var screenBeatSpaces = (FlxG.height / 100);
	var focusBeat = 5; // this is the beat where things align on screen (the one right in front of the player)

	var comboText:FlxText;
	var comboCounter:Int = 0;

	var filters:Array<BitmapFilter> = new Array<BitmapFilter>();
	var blurFilter:BlurFilter = new BlurFilter(2, 0, openfl.filters.BitmapFilterQuality.HIGH);

	var isShaderActive:Bool;
	var shader:Vhs;
	var vhsFilter:ShaderFilter;

	var allowBeats:Bool = true;

	var allowSpawning:Bool = true;

	var beatTracker:BeatTracker;

	// Failure text
	var _txtDontGiveUp:FlxText;
    var _txtPressSpace:FlxText;
    var _showRetryText:Bool = false;

	var lastTick:Float = 0.0;
	var tickDiff:Float = 0.0;

	var currentBeat:Int = 0;

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

	var level:Level;

	override public function create()
	{
		super.create();

		level = new Level(defaultBpm, defaultPixPerBeat);
		// level.initTestBeatEvents(laneCoords);
		level.addSegmentQueuedListener(parseBeatEvents);
		level.loadOgmoMap();
		level.addToState(this);

		comboText = new FlxText(10, FlxG.height-45, 100, "0", 30);
		add(comboText);

		loadRetryText();

		timePerBeat = 60.0/level.bpm;
		halfTime = timePerBeat/2;
		trace("timePerBeat: " + timePerBeat);
		trace("halfTime: " + halfTime);

		var shaderInput = new ShaderInput<BitmapData>();
		var noiseBitmap = new FlxSprite(0,0, "assets/images/NoiseTexture.png");
		shaderInput.input = noiseBitmap.pixels.clone();

		camera.setFilters(filters);

		shader = new Vhs();
		shader.iTime.value = [0];
		vhsFilter = new ShaderFilter(shader);

		FlxG.debugger.visible = true;

		// #if !FLX_NO_DEBUG
		// var y = 0;
		// while (y < FlxG.height) {
		// 	var divider = new FlxSprite(FlxG.width / 2, y, AssetPaths.divider__png);
		// 	divider.scale.set(FlxG.width / divider.width, 1);
		// 	add(divider);
		// 	if (y == focusBeat * level.pixelsPerBeat) {
		// 		divider.alpha = 1;
		// 	} else {
		// 		divider.alpha = 0.5;
		// 	}
		// 	y += level.pixelsPerBeat;
		// }
		// #end

		add(beaters);

		actions = new Actions();

		player = new Player(0, 0);
		player.x = laneCoords[playerLane] - player.width/2;
		player.y = (focusBeat * level.pixelsPerBeat) + 30;

		playerGroup.add(player);
		add(playerGroup);

		beatSpeaker = new BeatSpeaker();
		add(beatSpeaker);

		beatTracker = new BeatTracker(this, 135, FlxG.height - 30);
		FmodManager.PlaySong(FmodSongs.Level1);
		FmodManager.RegisterCallbacksForSong(beat, FmodCallback.TIMELINE_BEAT);
	}

	private function parseBeatEvents(events:Array<BeatEvent>) {
		for (e in events) {
			// floor this so we make sure to render sooner rather than later
			var beginRenderBeat = Math.floor(1.0 * e.impactBeat - (focusBeat / e.speed));

			// move them one beat earlier so they spawn without their jets hanging in from the top of the screen
			beginRenderBeat--;

			// trace(e, " starting at ", beginRenderBeat);

			// the impact y-coord  minus   how many beats on screen   times  how fast our ship moves
			e.sprite.y = (focusBeat * level.pixelsPerBeat) - (e.impactBeat - beginRenderBeat) * level.pixelsPerBeat * e.speed;
			// we want things to be lined up based on the bottom of the ship
			e.sprite.y -= e.sprite.body.height;
			e.sprite.startY = e.sprite.y;
			if (!renderEvents.exists(beginRenderBeat)) {
				renderEvents[beginRenderBeat] = new Array<BeatEvent>();
			}

			renderEvents[beginRenderBeat].push(e);
		}
	}

	private function beat() {

		if (!allowBeats){
			return;
		}

		beatTracker.SpawnLines();

		beatSpeaker.handleBeat();
		beatTime = Date.now().getTime();
		beatAwaitingProcessing = true;

		FlxG.camera.shake(0.0025, 0.05);
		filters.push(blurFilter);
		Timer.delay(()->{
			filters.remove(blurFilter);
		}, 100);

		currentBeat++;
		level.setBeat(currentBeat);

		// cancel any in-progress tweens
		for (t in tweens) {
			if (!t.finished) {
				t.cancelChain();
			}
		}
		tweens.resize(0);

		if (renderEvents.exists(currentBeat)) {
			for (e in renderEvents[currentBeat]) {
				beaters.add(e.sprite);
				add(e.sprite);
				e.sprite.y = e.sprite.startY;
				enableParentedSprite(e.sprite.body);
				e.sprite.speed = e.speed;
				e.sprite.beat = 0;
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
				ship.startY + ship.beat * (ship.speed * level.pixelsPerBeat),
				60.0 / level.bpm)
			);
		}
	}

	private function resetBeatVars() {
		if (playerTween == null || playerTween.finished) {
			alignPlayerToLane();
		}
	}

	private function alignPlayerToLane():Bool {
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
			return true;
		}
		return false;
	}

	private function killPlayer(playerPs: ParentedSprite) {
		disableParentedSprite(playerPs);
		FmodManager.PlaySoundOneShot(FmodSFX.Explosion);
		var shipExplosion:FlxSprite = new FlxSprite();
		shipExplosion.loadGraphic(AssetPaths.shipExplode__png, true, 160, 980, true);
		shipExplosion.setPosition(playerPs.x-50, playerPs.y-850);
		shipExplosion.animation.add("explode", [0,1,2,3,4,5,6,7,8,9,10,11], 12, false);
		shipExplosion.animation.play("explode");
		var explosionTween = FlxTween.tween(shipExplosion, { x: shipExplosion.x, y: shipExplosion.y+1800}, 1.8);
		FmodManager.SetEventParameterOnSong("Silence", 1);
		explosionTween.onComplete = (t)->{
			Rewind();
		};

		add(shipExplosion);
		comboCounter = 0;
		TextPop.pop(Std.int(playerPs.x), Std.int(playerPs.y), "Pink Floyd'd", new FlyBack(-300, 1), 25);
	}

	private function handlePlayerCarOverlap(playerPs: ParentedSprite, ai: ParentedSprite) {
		disableParentedSprite(ai);

		killPlayer(playerPs);
	}

	private function handlePlayerWallOverlap(playerPs: ParentedSprite, wall: FlxSprite) {
		killPlayer(playerPs);
	}

	private function Rewind() {

		Timer.delay(()->{
			allowBeats = false;
			FmodManager.StopSong();
			var fmodRewind = FmodManager.PlaySoundWithReference(FmodSFX.Rewind);
			level.groundSpeed = 0;
			// cancel any in-progress tweens
			for (t in tweens) {
				if (!t.finished) {
					t.cancelChain();
				}
			}
			FmodManager.RegisterCallbacksForSound(fmodRewind, ()->{
				level.rewind = true;
				level.groundSpeed = currentBeat;
				isShaderActive = true;
				filters.push(vhsFilter);
				tweens.resize(0);
				// add reverse tweens
				for (ship in beaters) {
					tweens.push(FlxTween.linearMotion(
						ship,
						ship.x,
						ship.y,
						ship.x,
						ship.y - currentBeat * (ship.speed * level.pixelsPerBeat),
						60.0 / level.bpm)
					);
				}

				FmodManager.RegisterCallbacksForSound(fmodRewind, ()->{
					level.rewind = false;
					allowBeats = true;
					// This should reference the level default in the future
					level.groundSpeed = 4;
					isShaderActive = false;
					filters.remove(vhsFilter);
					tweens.resize(0);
					currentBeat = 0;
					level.setBeat(currentBeat);
					FmodManager.SetEventParameterOnSong("Silence", 0);
					FmodManager.SetEventParameterOnSong("Miss", 0);
					FmodManager.PlaySong(FmodSongs.Level1);
					playerLane = 2;
					player.x = laneCoords[playerLane] - player.width/2;
					enableParentedSprite(player.ship);
					FmodManager.RegisterCallbacksForSong(beat, FmodCallback.TIMELINE_BEAT);
					beaters.clear();
					level.resetTrack();
				}, FmodCallback.STOPPED);
			}, FmodCallback.TIMELINE_MARKER);
		}, 250);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		var timestamp = Date.now().getTime();
		FmodManager.Update();

		shader.iTime.value[0] += elapsed;
		if (FlxG.keys.justPressed.P)
		{
				isShaderActive = !isShaderActive;
				if (isShaderActive) {
					filters.push(vhsFilter);
				} else {
					filters.remove(vhsFilter);
				}
		}

		if (playerTween == null || playerTween.finished) {
			if (actions.left.check()) {
				targetPlayerLane = playerLane - 1;
				if(alignPlayerToLane() && player.active) {
					calculateBeatScore(timestamp);
				}
			}

			if (actions.right.check()) {
				targetPlayerLane = playerLane + 1;
				if(alignPlayerToLane() && player.active) {
					calculateBeatScore(timestamp);
				}
			}
		}

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

		FlxG.overlap(playerGroup, beaters, handlePlayerCarOverlap);

		comboText.text = Std.string(comboCounter);

		// Level updates
		level.update(elapsed);
		if (level.activeSegment != null) {
			FlxG.collide(playerGroup, level.activeSegment.getTrack(), handlePlayerWallOverlap);
		}
	}

	private function calculateBeatScore(ts:Float) {
		var diff = Math.abs(ts - beatTime) / 1000;
		if (diff > halfTime) {
			diff = Math.abs(diff - timePerBeat);
		}

		if (diff < timePerBeat / 4) {
			TextPop.pop(Std.int(player.x), Std.int(player.y), "Great!", new FlyBack(-300, 1), 25);
			comboCounter++;
		} else if (diff < timePerBeat / 3) {
			TextPop.pop(Std.int(player.x), Std.int(player.y), "Miss", new FlyBack(-300, 1), 25);
			resetCombo();
		} else {
			TextPop.pop(Std.int(player.x), Std.int(player.y), "Miss", new FlyBack(-300, 1), 25);
			resetCombo();
		}
	}

	private function disableParentedSprite(parentedSprite: ParentedSprite) {
		parentedSprite.visible = false;
		parentedSprite.parent.visible = false;
		parentedSprite.active = false;
		parentedSprite.parent.active = false;
		parentedSprite.allowCollisions = 0;
	}

	private function enableParentedSprite(parentedSprite: ParentedSprite) {
		parentedSprite.visible = true;
		parentedSprite.parent.visible = true;
		parentedSprite.active = true;
		parentedSprite.parent.active = true;
		parentedSprite.allowCollisions = FlxObject.ANY;
	}

	private function loadRetryText() {
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

	private function resetCombo() {
		comboCounter = 0;
		FmodManager.PlaySoundOneShot(FmodSFX.ComboLost);
		FmodManager.SetEventParameterOnSong("Miss", 1);
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

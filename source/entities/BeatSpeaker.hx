package entities;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;

class BeatSpeaker extends FlxSprite {
    public function new() {
        super();

        loadGraphic(AssetPaths.speakerTest__png, true, 80, 80);
        x = FlxG.width - width;

		animation.add("sound", [1, 0], 10, false);
        animation.play("sound");
    }

    public function handleBeat() {
        animation.play("sound", true);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
    }
}

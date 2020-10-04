package level;

import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.FlxG;

using flixel.util.FlxSpriteUtil;

class Ground extends FlxSpriteGroup {
    public function new() {
        super();
    }

    public function handleBeat() {
        var line = new FlxSprite();
        line.makeGraphic(FlxG.width, 1, FlxColor.WHITE, true);
        add(line);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        for (l in this) {
            if (!l.isOnScreen()) {
                l.kill();
            }

            l.y += 500 * elapsed;
        }
    }
}
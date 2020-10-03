package level;

import openfl.Assets;
import entities.Ship;
import events.BeatEvent;

class LevelIO {
    public static function loadFromJSON(path: String): Level {
        var jsonFileStr = Assets.getBytes(path).toString();
        var lvlJson = haxe.Json.parse(jsonFileStr);

        var lvl = new Level();
        lvl.name = lvlJson.name;
        lvl.beatEvents = lvlJson.beatEvents.map((be) -> {
            return new BeatEvent(be.beat, be.speed, new Ship(be.ship.x, 0));
        });

        return lvl;
    }

    public static function saveToJSON(path: String, lvl: Level) {
        #if html5
        trace("saveToJSON does not work in HTML5, use an OS native build instead");
        return;
        #else
        var lvlJson = {
            name: lvl.name,
            beatEvents: lvl.beatEvents.map((be) -> {
                return {
                    beat: be.beat,
                    speed: be.speed,
                    ship: {
                        x: be.ship.x,
                    }
                };
            }),
        };

        var jsonFileStr:String = haxe.Json.stringify(lvlJson);
        sys.io.File.saveContent(path, jsonFileStr);
        #end
    }
}
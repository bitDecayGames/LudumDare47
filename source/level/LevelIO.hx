package level;

import openfl.Assets;
import entities.Ship;
import events.BeatEvent;
import js.html.File;
import js.html.URL;
import js.Browser.document;

class LevelIO {
    public static function loadFromJSON(path: String): Level {
        var jsonFileStr = Assets.getBytes(path).toString();
        var lvlJson = haxe.Json.parse(jsonFileStr);

        var lvl = new Level();
        lvl.name = lvlJson.name;
        lvl.beatEvents = lvlJson.beatEvents.map((be) -> {
            return new BeatEvent(be.beat, be.speed, new Ship(be.ship.x, 0, false));
        });

        return lvl;
    }

    public static function saveToJSON(path: String, lvl: Level) {
        var lvlJson = {
            name: lvl.name,
            beatEvents: lvl.beatEvents.map((be) -> {
                return {
                    beat: be.impactBeat,
                    speed: be.speed,
                    ship: {
                        x: be.sprite.x,
                    }
                };
            }),
        };
        var jsonFileStr:String = haxe.Json.stringify(lvlJson);

        #if html5
        saveToJSONWeb(jsonFileStr);
        #else
        sys.io.File.saveContent(path, jsonFileStr);
        #end
    }

    private static function saveToJSONWeb(jsonStr: String) {
        var linkEleId = "downloadLink";
        var fileName = "level.json";

        var linkEle = document.getElementById(linkEleId);
        if (linkEle == null) {
            linkEle = document.createElement("a");
            linkEle.setAttribute("id", linkEleId);
            linkEle.setAttribute("target", "_blank");
            linkEle.setAttribute("download", fileName);
            document.body.appendChild(linkEle);
        }

        var file = new File([jsonStr], fileName, {
            type: "application/json"
        });
        var url = URL.createObjectURL(file);
        linkEle.setAttribute("href", url);
        linkEle.click();
    }
}
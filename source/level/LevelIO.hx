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
        var lvl = haxe.Json.parse(jsonFileStr);
        return cast (lvl, Level);
    }

    public static function saveToJSON(path: String, lvl: Level) {
        var jsonFileStr:String = haxe.Json.stringify(lvl, null, "  ");

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
package level;

import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;
import events.BeatEvent;
import entities.Ship;

class LevelEditor extends FlxSpriteGroup {  
    var laneCoords: Array<Float>;

    public function new(laneCoords: Array<Float>) {
        super();

        this.laneCoords = laneCoords;
    }

    public function addBeatEvent(lvl: Level, mousePos: FlxPoint, currentBeat: Int): BeatEvent {
        var closestLaneX = getClosestLaneX(mousePos.x);
        // TODO Predict this correctly off bpm
        var eventBeat = currentBeat + 7;
        var eventSpeed = 1;
        
        var be = new BeatEvent(eventBeat, eventSpeed, new Ship(closestLaneX, 0));
        lvl.beatEvents.push(be);
        return be;
    }

    private function getClosestLaneX(x: Float): Float {
        var numLanes = laneCoords.length - 1;
        for (i in 0...numLanes - 1) {
            var leftLaneX = laneCoords[i];

            // TODO Implement rest
            // Consider converting lane to it's own object
        }

        return laneCoords[numLanes];
    }
}
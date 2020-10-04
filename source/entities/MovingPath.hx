package entities;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxPath;

class MovingPath extends FlxPath {

	public var scrollSpeed:FlxPoint;

	public function new(scrollSpeed:FlxPoint, ?Nodes:Array<FlxPoint>) {
		super(Nodes);

		this.scrollSpeed = scrollSpeed;
	}

	override public function update(delta:Float) {
		super.update(delta);

		// we will handle our y
		object.velocity.y = 0;

		// FlxG.watch.addQuick("pre obj vel: ", object.velocity);

		// object.velocity.add(scrollSpeed.x, scrollSpeed.y);
		// FlxG.watch.addQuick("pst obj vel: ", object.velocity);

		for (n in nodes) {
			n.add(scrollSpeed.x * delta, scrollSpeed.y * delta);
		}
	}
}
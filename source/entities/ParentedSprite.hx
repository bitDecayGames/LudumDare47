package entities;

import flixel.FlxSprite;

class ParentedSprite extends FlxSprite {
	public var parent:FlxSprite;

	public function new(parent:FlxSprite) {
		super();
		this.parent = parent;
	}
}
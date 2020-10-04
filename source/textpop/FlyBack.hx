package textpop;

import flixel.tweens.FlxEase;
import com.bitdecay.textpop.style.Style;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;

class FlyBack implements Style {
	private var height:Float;
	private var life:Float;

	public function new(height:Float, life:Float = 1.0) {
		this.height = height;
		this.life = life;
	}

	public function Stylize(obj:FlxObject):FlxTween {
		var flxObj:FlxObject = obj;
		var tween = FlxTween.tween(flxObj, { y: flxObj.y - height, alpha: 0}, life, {ease: FlxEase.quadIn});
		return tween;
	}
}
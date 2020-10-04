package shaders;

import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxShader;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;

class NormalMapShader extends FlxShader {
	@:glFragmentSource('
		#pragma header
		uniform sampler2D normalTex;
		uniform vec2 lightPos;
		uniform float lightHeight;
		uniform float ambientRatio;

		void main()
		{
			vec4 toLight = vec4(lightPos - openfl_TextureCoordv, lightHeight, 0);
			toLight.y *= -1.0;

			vec4 source = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec4 normal = texture2D(normalTex, openfl_TextureCoordv);

			normal = normalize(normal * 2.0 - 1.0);

			float cos_angle = dot(normal, toLight);
  			cos_angle = clamp(cos_angle, ambientRatio, 1.0);

			gl_FragColor = vec4(vec3(source) * cos_angle, source.a);
		}')
	public function new(spr:FlxSprite) {
		super();
		setNormalMapSprite(spr);
		setLightPosition(new FlxPoint(0, 0));
		setLightHeight(1);
		setAmbientRatio(1.0);
	}

	public function setNormalMapSprite(spr:FlxSprite) {
		normalTex.input = spr.pixels;
	}

	public function setLightPosition(pos:FlxPoint) {
		lightPos.value = [pos.x, pos.y];
	}

	public function setLightHeight(height:Float) {
		lightHeight.value = [height];
	}

	public function setAmbientRatio(ratio:Float) {
		if (ratio < 0)
			ambientRatio.value = [0.0];
		else if (ratio > 1.0)
			ambientRatio.value = [1.0];
		else
			ambientRatio.value = [ratio];
	}
}

package shaders;

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

		void main()
		{
			vec4 toLight = vec4(lightPos - openfl_TextureCoordv, lightHeight, 0);
			toLight.y *= -1.0;

			vec4 source = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec4 normal = texture2D(normalTex, openfl_TextureCoordv);

			normal = normalize(normal * 2.0 - 1.0);

			float cos_angle = dot(normal, toLight);
  			cos_angle = clamp(cos_angle, 0.2, 1.0);

			gl_FragColor = vec4(vec3(source) * cos_angle, source.a);

			// if (openfl_TextureCoordv.x + openfl_TextureCoordv.y < 1.0) {
			// 	gl_FragColor.r = 1.0;
			// 	gl_FragColor.g = 0.0;
			// 	gl_FragColor.b = 0.0;
			// 	gl_FragColor.a = 1.0;
			// }

			// if (abs(openfl_TextureCoordv.x - lightPos.x) < 0.01 && abs(openfl_TextureCoordv.y - lightPos.y) < 0.01) {
			// 	gl_FragColor.r = 0.0;
			// 	gl_FragColor.g = 1.0;
			// 	gl_FragColor.b = 0.0;
			// 	gl_FragColor.a = 1.0;
			// }
		}')
	public function new(spr:FlxSprite) {
		super();
		setNormalMapSprite(spr);
		setLightPosition(new FlxPoint(0, 0));
		setLightHeight(1);
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
}

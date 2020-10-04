package shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.FlxSprite;
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
			// calculate the vector going from the texture coord to the light source and add some height to this vector
			vec4 toLight = vec4(lightPos - openfl_TextureCoordv, lightHeight, 0);

			// invert the y value since uv coords have reversed coordinate system
			toLight.y *= -1.0;

			// pull out the color vectors from the source image and the normal image
			vec4 source = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec4 normal = texture2D(normalTex, openfl_TextureCoordv);

			// normalize the normal vector (honestly not sure why we need the *2.0-1 thing here, but it doesnt work without it)
			normal = normalize(normal * 2.0 - 1.0);

			// calculate what the angle is between the normal vector and the pixel to the light source.  An angle of 1.0 means the light source and the normal are parallel, and an angle of 0.0 means they are perpendicular
			float cos_angle = dot(normal, toLight);

			// clamp the "angle" which is now basically the intensity of the light on the pixel and bring up the bottom of the clamp to match the ambientRatio which basically just makes sure each pixel is drawn with at least SOME color instead of being completely black (use 0.0 for ratio if you want completely black)
  			cos_angle = clamp(cos_angle, ambientRatio, 1.0);

			// multiply the rgb of the source color vector by the angle/intensity to either brighten or dim the color at this pixel, and just use the original alpha from the source directly, dont manipulate that with light
			gl_FragColor = vec4(vec3(source) * cos_angle, source.a);
		}')
	public function new(spr:FlxSprite) {
		super();
		setNormalMapSprite(spr);
		setLightPosition(new FlxPoint(0, 0));
		setLightHeight(1);
		setAmbientRatio(1.0);
	}

	// this is the normal sprite that you are going to pass into the shader
	public function setNormalMapSprite(spr:FlxSprite) {
		normalTex.input = spr.pixels;
	}

	// for this to work properly, you will need to convert your light position into local coordinates to the sprite, then into a ratio between 0-1 based on the sprite's total width (if it is a sprite sheet, you will need to take frameWidth * numOfFrames)
	public function setLightPosition(pos:FlxPoint) {
		lightPos.value = [pos.x, pos.y];
	}

	// I'm not totally sure this is really what I'm saying it is, but theoretically this changes how high the light is in the "sky" compared to the flat sprite is on the "ground"
	public function setLightHeight(height:Float) {
		lightHeight.value = [height];
	}

	// setting this ratio to 1 will basically ignore the lightsource completely and just bathe everything in full light, while setting to 0 will cause the sprite to draw black if there is no light directly on it (black, not transparent)
	public function setAmbientRatio(ratio:Float) {
		if (ratio < 0)
			ambientRatio.value = [0.0];
		else if (ratio > 1.0)
			ambientRatio.value = [1.0];
		else
			ambientRatio.value = [ratio];
	}
}

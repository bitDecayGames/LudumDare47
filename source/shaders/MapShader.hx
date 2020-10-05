package shaders;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.ShaderParameter;

class MapShader extends FlxShader {
	@:glFragmentSource('
		#pragma header
		
		uniform vec2 lightPos1;
		uniform vec2 lightPos2;
		uniform vec2 lightPos3;
		uniform vec2 lightPos4;
		uniform vec2 lightPos5;
		uniform vec2 lightPos6;
		uniform vec2 lightPos7;
		uniform vec2 lightPos8;
		
		uniform vec3 dayColor;
		uniform vec3 fireColor;

		uniform float fireRadius;

		uniform bool debugLoc;
	
		vec3 makeLight(vec2 lightPos)
		{
			
			float lightIntensity = 0.5;
			vec3 darknessColor = vec3(0.0, 0.0, 0.0);
			vec3 timeInfluence = mix(darknessColor, fireColor, lightIntensity);
			float fireInfluence = fireRadius - distance(openfl_TextureCoordv, lightPos);
			
		
			// normalize to a linear 0.0-1.0 value
			fireInfluence = clamp(fireInfluence, 0.0, fireRadius) / fireRadius;

			// reverse exponential decay
			float revExpFireInfluence = (1.0 - pow(fireInfluence - 1.0, 2.0));

			// exponential decay
			float expfireInfluence = pow(fireInfluence, 2.0);

			// weight toward the reverse exp influence
			float weight = 0.1;

			// Weighted average
			float expInfluence = 1.0 - fireRadius;
			fireInfluence = revExpFireInfluence * (1.0-expInfluence + 0.1);
			fireInfluence += expfireInfluence * (expInfluence - 0.1);

			// Straight average
			// fireInfluence = revExpFireInfluence + expfireInfluence;
			// fireInfluence /= 2.0;

			// This line is for testing the raw fire influence
			// gl_FragColor.rgba = vec4(fireInfluence, fireInfluence, fireInfluence, 1.0);

			vec3 totalInfluence = mix(timeInfluence, fireColor, fireInfluence);

			//gl_FragColor.rgb = gl_FragColor.rgb * totalInfluence;
			return totalInfluence;
		}


		void main()
		{
			gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);
			gl_FragColor.rgb = gl_FragColor.rgb * makeLight(lightPos1);
			gl_FragColor.rgb = gl_FragColor.rgb * makeLight(lightPos2);
			
		}
		
		')

	public function new() {
		super();
		this.dayColor.value = [1.0, 1.0, 1.0];
		//this.lightPos.value = [0.25, 0.5];
		this.fireColor.value = [1.0, 1.0, 1.0];
		this.fireRadius.value = [0.2];
		this.lightPos1.value = [0, 0];
		this.debugLoc.value = [false];
	}
}

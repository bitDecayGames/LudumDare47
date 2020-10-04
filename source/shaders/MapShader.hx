package shaders;

import flixel.system.FlxAssets.FlxShader;

class MapShader extends FlxShader {
	@:glFragmentSource('
		#pragma header
		
		//uniform vec3 darknessColor;
		uniform vec3 dayColor;
		uniform vec3 fireColor;

		uniform float fireRadius;

		uniform bool debugLoc;
		uniform float lights[3]; // series of lights in the form (x, y, type), flattened
		uniform int numLights;
		void main()
		{
			gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);
			
			for (int i = 0; i < 1; i++) {
				if (i > numLights) {
					break;
				}

			
				vec2 firePos = vec2(lights[i * 3], lights[i * 3 + 1]);

				float lightIntensity = 0.25;
				vec3 darknessColor = vec3(0.0, 0.0, 0.0);
				vec3 timeInfluence = mix(darknessColor, fireColor, lightIntensity);
				float fireInfluence = fireRadius - distance(openfl_TextureCoordv, firePos);
				
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
	
				// This line is for testing the raw fire influence
				// gl_FragColor.rgba = vec4(fireInfluence, fireInfluence, fireInfluence, 1.0);
	
				vec3 totalInfluence = mix(timeInfluence, fireColor, fireInfluence);
	
				gl_FragColor.rgb = gl_FragColor.rgb * totalInfluence;
			
			}
		}')

	public function new() {
		super();
		this.dayColor.value = [1.0, 1.0, 1.0];
		//this.firePos.value = [0.25, 0.5];
		this.fireColor.value = [1.0, 1.0, 1.0];
		this.fireRadius.value = [0.2];
		this.numLights.value = [1];
		this.lights.value = [
			0.25, 0.5, 1
		];
		this.debugLoc.value = [false];
	}
}

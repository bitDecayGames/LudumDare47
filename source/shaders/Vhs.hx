package shaders;

import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class Vhs extends FlxShader
{
	@:glFragmentSource('
        #pragma header

        uniform float iTime;
        uniform sampler2D noiseTexture;
        
        float noise(vec2 p)
        {
            float s = flixel_texture2D(noiseTexture,vec2(1.,2.*cos(iTime))*iTime*8. + p*1.).x;
            s *= s;
            return s;
        }

        float onOff(float a, float b, float c)
        {
            return step(c, sin(iTime + a*cos(iTime*b)));
        }

        float ramp(float y, float start, float end)
        {
            float inside = step(start,y) - step(end,y);
            float fact = (y-start)/(end-start)*inside;
            return (1.-fact) * inside;
            
        }
        
        float stripes(vec2 uv)
        {
            
            float noi = noise(uv*vec2(0.5,1.) + vec2(1.,3.));
            return ramp(mod(uv.y*4. + iTime/2.+sin(iTime + sin(iTime*0.63)),1.),0.5,0.6)*noi;
        }

        vec3 getVideo(vec2 uv)
        {
            vec2 look = uv;
            float window = 1./(1.+20.*(look.y-mod(iTime/4.,1.))*(look.y-mod(iTime/4.,1.)));
            look.x = look.x + sin(look.y*10. + iTime)/50.*onOff(4.,4.,.3)*(1.+cos(iTime*80.))*window;
            float vShift = 0.4*onOff(2.,3.,.9)*(sin(iTime)*sin(iTime*20.) + 
                                                 (0.5 + 0.1*sin(iTime*200.)*cos(iTime)));
            look.y = mod(look.y + vShift, 1.);
            vec3 video = vec3(flixel_texture2D(bitmap,look));
            return video;
        }

        vec2 screenDistort(vec2 uv)
        {
            uv -= vec2(.5,.5);
            uv = uv*1.2*(1./1.2+2.*uv.x*uv.x*uv.y*uv.y);
            uv += vec2(.5,.5);
            return uv;
        }

        void main()
        {
            vec2 uv = openfl_TextureCoordv;
            
            // Flicker the video
            vec3 video = getVideo(uv);
            
	        video += stripes(uv);
            video += noise(uv*2.)/2.;
            
            // Add the pulsing black boarders
            float vigAmt = 3.+.3*sin(iTime + 5.*cos(iTime*5.));
            float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));
            video *= vignette;

            // Add the spaced lines that slowly move down
            video *= (12.+mod(uv.y*30.+iTime,1.))/13.;

			gl_FragColor = vec4(video, 1.0);
        }')

    public function new()
    {
        super();
    }    
}
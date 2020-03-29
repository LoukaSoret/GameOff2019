shader_type spatial;
//render_mode diffuse_toon,specular_disabled	;
//render_mode diffuse_toon, specular_toon;
render_mode blend_mix,depth_draw_alpha_prepass,cull_back,diffuse_burley,specular_schlick_ggx;

uniform int _DeformationSeed = 0;
uniform float _Deformation : hint_range(0,1) = 0.5;
uniform vec4 _Color : hint_color = vec4(0.5,0.5,0.5,1.0);
uniform vec4 _OutlineColor : hint_color = vec4(0,0,0,1.0);
uniform sampler2D _HatchingTexture;
uniform sampler2D _HatchingNoiseTexture;
uniform vec2 _HatchingScale = vec2(1);
uniform float _HatchingThreshold1 : hint_range(0,1) = 0.3;
uniform float _HatchingThreshold2 : hint_range(0,1) = 0.5;
uniform float _HatchingFrequency = 8.0;
uniform vec4 _MossColor : hint_color = vec4(0,0,0,1.0);
uniform float _MossThreshold : hint_range(0,1) = 0.5;

	float hash( float n )
	{
	    return fract(sin(n)*43758.5453);
	}

	float noise( vec3 x )
	{
	    // The noise function returns a value in the range -1.0f -> 1.0f

	    vec3 p = floor(x);
	    vec3 f = fract(x);

	    f       = f*f*(3.0-2.0*f);
	    float n = p.x + p.y*57.0 + 113.0*p.z;

	    return mix(mix(mix( hash(n+0.0), hash(n+1.0),f.x),
	                   mix( hash(n+57.0), hash(n+58.0),f.x),f.y),
	               mix(mix( hash(n+113.0), hash(n+114.0),f.x),
	                   mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
	}


void vertex(){
	float d = (noise(VERTEX.xyz+float(_DeformationSeed)) * 2.0 - 1.0)*_Deformation;
	VERTEX.x += d;
	VERTEX.y += d;
	VERTEX.z += d;
}

vec2 hash2(vec2 p) {
  p = vec2( dot(p,vec2(127.1,311.7)),
        dot(p,vec2(269.5,183.3)) );
 
  return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float gnoise(in vec2 p) {
  vec2 i = floor( p );
  vec2 f = fract( p );
   
  vec2 u = f*f*(3.0-2.0*f);
 
  return mix( mix( dot( hash2( i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ),
           dot( hash2( i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
          mix( dot( hash2( i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ),
           dot( hash2( i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
}

float pnoise(vec2 p,float amplitude,float frequency,float persistence, int nboctaves, float power) {
  float a = amplitude;
  float f = frequency;
  float n = 0.0;
 
  for(int i=0;i<nboctaves;++i) {
    n = n+a*gnoise(p*f);
    f = f*2.;
    a = a*persistence;
  }
 
  return pow(n,power);
}

void fragment(){
	vec3 col = _Color.rgb;
	
	//float noiseH = texture(_HatchingNoiseTexture,UV).r;
	float noiseM = pnoise(UV+vec2(5.0*float(_DeformationSeed),10.0*float(_DeformationSeed)),2.0,20.0,0.5,2,4)*0.8+0.4;
	if(noiseM>_MossThreshold)
		col = _MossColor.rgb;
	else if (noiseM>_MossThreshold-0.03)
		col = _OutlineColor.rgb;
	float noiseH = pnoise(UV,2.0,_HatchingFrequency,0.5,1,1.0)*0.5+0.5;
	float hatching1 = texture(_HatchingTexture,UV*_HatchingScale).r;
	if(hatching1<=0.5 && noiseH>_HatchingThreshold1)
		col = mix(col,_OutlineColor.rgb, clamp((noiseH-_HatchingThreshold1)/0.05,0,1));
		
	float hatching2 = texture(_HatchingTexture,UV*vec2(0,-1)*_HatchingScale).r;
	if(hatching2<=0.5 && noiseH>_HatchingThreshold2)
		col = mix(col,_OutlineColor.rgb, clamp((noiseH-_HatchingThreshold2)/0.05,0,1));
	
	
	ALBEDO = col;
	//EMISSION = col;
	//TRANSMISSION = col;
}

/*
void light(){
	float NdotL =  dot(normalize(LIGHT), NORMAL);
	float intensity = NdotL>0.5?1.0:-1.0;

	if(intensity<=0.0){
		DIFFUSE_LIGHT = ALBEDO;//_OutlineColor.rgb;
	}
	else
		DIFFUSE_LIGHT = intensity * TRANSMISSION;
}
*/
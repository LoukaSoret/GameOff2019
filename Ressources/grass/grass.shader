shader_type spatial;
render_mode blend_mix,depth_draw_alpha_prepass,cull_disabled,diffuse_burley,specular_schlick_ggx;

// Perlin Parameters
uniform float amplitude : hint_range(0,10) = 2;
uniform float frequency : hint_range(0,100) = 4;
uniform float persistence : hint_range(0,1) = 0.2;
uniform int nboctaves : hint_range(0,10) = 4;

uniform vec4 colorTop : hint_color;
uniform vec4 colorBottom : hint_color;

uniform float _YSpacing : hint_range(0,1) = 1.0;
//uniform sampler2D grassTexture;

uniform sampler2D _NoiseTexture;
uniform vec3 _NoiseScale = vec3(1,1,1);

uniform float _Wind = 0.002;

uniform sampler2D grasTexture;

varying vec2 vertex_position;
varying float height;

// Noise functions
/*
vec2 hash(vec2 p) {
	p = vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)));
	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float gnoise(vec2 p) {
	vec2 i = floor( p );
	vec2 f = fract( p );
	vec2 u = f*f*(3.0-2.0*f);
	return mix( mix( dot( hash( i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ),
				dot( hash( i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
				mix( dot( hash( i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ),
				dot( hash( i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
}

float pnoise(vec2 p,float amp,float freq,float pers, int nboct) {
	float a = amp;
	float f = freq;
	float n = 0.0;
	for(int i=0;i<nboct;++i) {
		n = n+a*gnoise(p*f);
		f = f*2.;
		a = a*pers;
	}
	return n;
}
*/

void vertex() {
	vertex_position = VERTEX.xz / 2.0;
	height = COLOR.r;
	VERTEX.y *= _YSpacing;
	//MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],CAMERA_MATRIX[1],CAMERA_MATRIX[2],WORLD_MATRIX[3]);
}

void fragment(){
	
	vec2 scrollUV = UV;
	scrollUV.x += _Wind/100.0*cos( TIME*1.0)*height;
	scrollUV.y += _Wind/100.0*cos( TIME*3.0)*height;
	vec4 col = mix(colorBottom,colorTop,height);
	col *= texture(grasTexture,UV*5.0);
	//float noise = pnoise(scrollUV*_NoiseScale,amplitude,frequency,persistence,nboctaves);
	float noise = texture(_NoiseTexture,scrollUV*_NoiseScale.xy).r*(1./_NoiseScale.z);
	
	ALPHA = 1.0;
	if(noise < height){
		ALPHA = 0.0;
	}
	
	if(ALPHA<height){
		ALPHA = 0.0;
	} else {
		ALPHA = 1.0;
	}
	ALPHA_SCISSOR = 1.0;
	//ALBEDO = vec3(noise);
    ALBEDO = col.rgb;
}
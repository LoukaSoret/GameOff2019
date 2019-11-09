shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform vec4 eyes_albedo : hint_color;

// Moss parameters
uniform sampler2D moss_noise : hint_black;
uniform vec4 moss_albedo : hint_color;
uniform float moss_scale : hint_range(0,100);
uniform sampler2D moss_threshold_gradient : hint_black;

// Perlin Parameters
uniform float moss_perlin_threshold : hint_range(0,1);
uniform float moss_amplitude : hint_range(0,10) = 2;
uniform float moss_frequency : hint_range(0,100) = 4;
uniform float moss_persistence : hint_range(0,1) = 0.2;
uniform int moss_nboctaves : hint_range(0,10) = 4;

// Cracks Parameters
uniform vec4 cracks_albedo : hint_color;
uniform float threshold : hint_range(0,1);
uniform float scale : hint_range(0,100);
uniform sampler2D cracks_noise : hint_black;
uniform sampler2D threshold_gradient : hint_black;

// Perlin Parameters
uniform float perlin_threshold : hint_range(0,1);
uniform float amplitude : hint_range(0,10) = 2;
uniform float frequency : hint_range(0,100) = 4;
uniform float persistence : hint_range(0,1) = 0.2;
uniform int nboctaves : hint_range(0,10) = 4;

// Material Parameters
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform sampler2D texture_metallic : hint_white;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_white;
uniform vec4 roughness_texture_channel;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset; 

// Noise functions
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

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	float perlin = pnoise(UV,amplitude,frequency,persistence,nboctaves);
	if(albedo_tex.a == 1.){
		ALBEDO = eyes_albedo.rgb;
	} else {
		if( perlin > perlin_threshold && texture(cracks_noise,UV*scale).r > texture(threshold_gradient,vec2(perlin/2.)).r){
			ALBEDO = cracks_albedo.rgb;
		} else {
			ALBEDO = albedo.rgb;
		}
		
		perlin = pnoise(UV,moss_amplitude,moss_frequency,moss_persistence,moss_nboctaves);
		if( perlin > moss_perlin_threshold && texture(moss_noise,UV*moss_scale).r > texture(moss_threshold_gradient,vec2(perlin)).r){
			ALBEDO = mix(ALBEDO,moss_albedo.rgb,0.75);
		}
	}
	
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
}

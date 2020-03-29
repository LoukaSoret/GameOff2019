shader_type spatial;
render_mode cull_front, unshaded;

uniform int _DeformationSeed = 0;
uniform float _Deformation : hint_range(0,1) = 0.5;
uniform vec4 _OutlineColor : hint_color = vec4(0,0,0,1);
uniform float _OutlineWidth : hint_range(0,1) = 0;

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
	
	VERTEX *= (1.0+_OutlineWidth);
}

void fragment(){
	ALBEDO = _OutlineColor.rgb;
}
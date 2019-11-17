/*
* Volumetric clouds
*
* Based on:
* - https://www.shadertoy.com/view/WslGWl
* - https://github.com/SebLague/Clouds
*
*/

shader_type spatial;
render_mode skip_vertex_transform, unshaded, depth_draw_alpha_prepass;

uniform vec3 _BoundsMin = vec3(-100,-100,-100);
uniform vec3 _BoundsMax = vec3(100,10,100);
uniform vec3 _CloudScale = vec3(8);

uniform float _Coverage : hint_range(0,1) = 0.3;
uniform float _Margin = 10.0;
uniform float _Density = 3;

uniform int _Steps : hint_range(0,256) = 128;
//uniform float _Precision : hint_range(0,1);
uniform int _StepsLight : hint_range(0,20) = 0;

uniform float _LightIntensity = 30.0;
uniform float _Absorption = 80.0;

uniform vec4 _CloudColor : hint_color = vec4(vec3(1),1);
uniform vec4 _LightColor : hint_color = vec4(1);

uniform float _Speed = 0.5;

uniform sampler3D _Noise3D;

vec2 rayBoxDst(vec3 bMin, vec3 bMax, vec3 ro, vec3 rd){
	vec3 t0 = (bMin-ro)/rd;
	vec3 t1 = (bMax-ro)/rd;
	vec3 tmin = min(t0,t1);
	vec3 tmax = max(t0,t1);
	
	float dstA = max(max(tmin.x,tmin.y),tmin.z);
	float dstB = min(tmax.x,min(tmax.y,tmax.z));
	
	float dstToBox = max(0,dstA);
	float dstInsideBox = max(0,dstB-dstToBox);
	return vec2(dstToBox,dstInsideBox);
}

varying mat4 CAMERA;
varying vec3 viewVector;

void vertex() {
	PROJECTION_MATRIX = mat4(1.0);
	CAMERA = CAMERA_MATRIX;
}

float get_density(vec3 p, float iTime){
	vec3 uvw = p * _CloudScale * 0.001;
	vec4 shape = texture(_Noise3D, uvw+vec3(0.5,0.5,iTime*0.2));
	
	float densityThreshold = (1.0-_Coverage);
	float density = max(0,shape.r-densityThreshold)*_Density;
	
	//marge
	float containerEdgeFadeDst = _Margin;
	float dstFromEdgeX = min(containerEdgeFadeDst, min(p.x - _BoundsMin.x, _BoundsMax.x - p.x));
	float dstFromEdgeZ = min(containerEdgeFadeDst, min(p.z - _BoundsMin.z, _BoundsMax.z - p.z));
	float dstFromEdgeY = min(containerEdgeFadeDst, min(p.y - _BoundsMin.y, _BoundsMax.y - p.y));
	float edgeWeight = min(dstFromEdgeY,min(dstFromEdgeZ,dstFromEdgeX))/containerEdgeFadeDst;
	
	return clamp(density*edgeWeight,0,1);
}

void fragment(){
	vec4 world = CAMERA * INV_PROJECTION_MATRIX * vec4(vec3(0), 1.0);
	vec3 worldSpaceCameraPos = world.xyz / world.w;

	vec4 v = INV_PROJECTION_MATRIX * vec4(SCREEN_UV*2.0-1.0 , 0, 1);
	vec4 vv = CAMERA_MATRIX * vec4(v.xyz,0.0);
	
	vec3 rd = normalize(vv.xyz);   
	vec3 ro =  worldSpaceCameraPos;//pos;
	
	vec2 rbi = rayBoxDst(vec3(_BoundsMin),vec3(_BoundsMax), ro, rd);
	float dstToBox = rbi.x;
	float dstInsideBox = rbi.y;
	ro =  worldSpaceCameraPos  + rd * dstToBox;
	
	float depthNL = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
    vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depthNL * 2.0 - 1.0, 1.0);
    vec3 pixel_position = upos.xyz / upos.w;
	
	float depth = length(pixel_position);
	
	float iTime = TIME*_Speed;
	
	//bool hit = dstInsideBox > 0.0 && dstToBox < depth;
	
	float dstTravelled = 0.0;
	float stepSize = dstInsideBox / float(_Steps) /* (1.1-_Precision)*/;
	float dstLimit = min(depth-dstToBox, dstInsideBox);
	
	float T = 1.0;
	vec4 color = vec4(0.0);
	
	while(dstTravelled<dstLimit){
		vec3 rp = ro + rd * dstTravelled;
		float density = get_density(rp,iTime);

		if(density>0.0){
			float tmp = density / float(_Steps);
			
			T *= 1.0 - (tmp * _Absorption);
			
			if (T <= 0.01)
			{
			    break;
			}
			
			//LIGHT
			 float Tl = 1.0;
            vec3 lp = rp;
            for (int j = 0; j < _StepsLight; j++)
            {
                float densityLight = get_density(lp,iTime);

                if (densityLight > 0.0)
                {
                    float tmpl = densityLight / float(_Steps);
                    Tl *= 1.0 - (tmpl * _Absorption);
                }
                if (Tl <= 0.01)
                {
                    break;
                }
                lp += vec3(10,100,10) * 0.5;//(20.0/float(_StepsLight));//TODO sun dir, zstep
            }

			float opacity = 50.0;
            float k = opacity * tmp * T;
            vec4 col1 = _CloudColor * k;
			
			//LIGHT
            float kl = _LightIntensity* tmp * T * Tl;
            vec4 col2 = _LightColor * kl;
			
            color += col1 + col2;
		}
		
		dstTravelled += stepSize;
	}

	vec3 bg = texture(SCREEN_TEXTURE,SCREEN_UV).rgb;
	vec3 col = bg*T + color.rgb;
	//col = mix(color.rgb,bg,T);
	ALPHA = 1.0;
	ALBEDO = col;

}
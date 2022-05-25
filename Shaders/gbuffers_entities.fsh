#version 120
#extension GL_EXT_gpu_shader4 : enable

//#define PCF
#define TORCH_AMOUNT 1.0 //[0.0 0.5 0.75 1. 1.2 1.4 1.6 1.8 2.0]
#define TORCH_R 1.0 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define TORCH_G 0.42 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.42 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define TORCH_B 0.11 //[0.0 0.05 0.1 0.11 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]

const int shadowMapResolution = 1024; //[512 768 1024 1536 2048 3172 4096 8192]


varying vec4 lmtexcoord;
varying vec4 color;
varying vec4 normalMat;

#define SHADOW_MAP_BIAS 0.8

uniform sampler2D texture;
uniform sampler2DShadow shadow;

uniform vec4 entityColor;
uniform vec4 lightCol;
uniform vec3 sunVec;
uniform vec3 upVec;

uniform vec2 texelSize;
uniform float skyIntensityNight;
uniform float skyIntensity;
uniform float sunElevation;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

//faster and actually more precise than pow 2.2
vec3 toLinear(vec3 sRGB){
	return sRGB * (sRGB * (sRGB * 0.305306011 + 0.682171111) + 0.012522878);
}

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define  projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec3 toScreenSpace(vec3 p) {
	vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
    vec3 p3 = p * 2. - 1.;
    vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return fragposition.xyz / fragposition.w;
}
float interleaved_gradientNoise(){
	vec2 coord = gl_FragCoord.xy;
	float noise = fract(52.9829189*fract(0.06711056*coord.x + 0.00583715*coord.y));
	return noise;
}

#ifdef PCF
const vec2 shadowOffsets[8] = vec2[8](vec2( -0.7071,  0.7071 ),
vec2( -0.0000, -0.8750 ),
vec2(  0.5303,  0.5303 ),
vec2( -0.6250, -0.0000 ),
vec2(  0.3536, -0.3536 ),
vec2( -0.0000,  0.3750 ),
vec2( -0.1768, -0.1768 ),
vec2( 0.1250,  0.0000 ));
#endif
float facos(float sx){
    float x = clamp(abs( sx ),0.,1.);
    float a = sqrt( 1. - x ) * ( -0.16882 * x + 1.56734 );
    return sx > 0. ? a : 3.14159265359 - a;
}	
#define SHADOW_MAP_BIAS 0.8
float calcDistort(vec2 worlpos){
	
	vec2 pos = worlpos * 1.165;
	vec2 posSQ = pos*pos;
	
	float distb = pow(posSQ.x*posSQ.x*posSQ.x + posSQ.y*posSQ.y*posSQ.y, 1.0 / 6.0);
	return 1.08695652/((1.0 - SHADOW_MAP_BIAS) + distb * SHADOW_MAP_BIAS);
}	
			
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
/* DRAWBUFFERS:1 */
void main() {



	gl_FragData[0] = texture2D(texture, lmtexcoord.xy)*color;
	gl_FragData[0].rgb = mix(gl_FragData[0].rgb,entityColor.rgb,entityColor.a);
	if (gl_FragData[0].a>0.1){
		vec3 albedo = toLinear(gl_FragData[0].rgb);
		
		vec3 normal = normalMat.xyz;
		vec3 fragpos = toScreenSpace(gl_FragCoord.xyz*vec3(texelSize,1.0));



		float NdotL = lightCol.a*dot(normal,sunVec);
		float NdotU = dot(upVec,normal);
		float diffuseSun = clamp(NdotL,0.0f,1.0f);
		float skyLight = (NdotU*0.4+1.0);

		vec3 direct = lightCol.rgb;


		//compute shadows only if not backface
		if (diffuseSun > 0.001) {
			vec3 p3 = mat3(gbufferModelViewInverse) * fragpos + gbufferModelViewInverse[3].xyz;
			vec3 projectedShadowPosition = mat3(shadowModelView) * p3 + shadowModelView[3].xyz;
			projectedShadowPosition = diagonal3(shadowProjection) * projectedShadowPosition + shadowProjection[3].xyz;
			
			//apply distortion
			float distortFactor = calcDistort(projectedShadowPosition.xy);
			projectedShadowPosition.xy *= distortFactor;
			//do shadows only if on shadow map
			if (abs(projectedShadowPosition.x) < 1.0-1.5/shadowMapResolution && abs(projectedShadowPosition.y) < 1.0-1.5/shadowMapResolution){
				const float sr = 1024./shadowMapResolution;
				float diffthresh = (facos(diffuseSun)*0.008*sr+0.00008*sr)/(distortFactor*distortFactor);	

				projectedShadowPosition = projectedShadowPosition * vec3(0.5,0.5,0.5/3.0) + vec3(0.5,0.5,0.5);
				
				#ifdef PCF
				float shading = 0.0;	
				float noise = interleaved_gradientNoise();
				mat2 noiseM = mat2( cos( noise*3.14159265359*2.0 ), -sin( noise*3.14159265359*2.0 ),
								   sin( noise*3.14159265359*2.0 ), cos( noise*3.14159265359*2.0 )
									);

				
				for(int i = 0; i < 8; i++){
					vec2 offsetS = shadowOffsets[i];
							
					float weight = 1.0+length(offsetS)*1.412*distortFactor*0.2;
					shading += shadow2D(shadow,vec3(projectedShadowPosition + vec3((noiseM*offsetS)*(distortFactor*0.2*1.412/shadowMapResolution),-diffthresh*weight))).x/8.0;
					}
				#endif

				
				#ifndef PCF
				projectedShadowPosition.z -= diffthresh;
				float shading = shadow2D(shadow,vec3(projectedShadowPosition)).x;

				#endif
				
				direct *= shading;
			}

		}
		
		direct *= (diffuseSun*lmtexcoord.w)*10.;
	
		float torch_lightmap = ((lmtexcoord.z*lmtexcoord.z)*(lmtexcoord.z*lmtexcoord.z))*(lmtexcoord.z*20.)+lmtexcoord.z;
	
		vec3 ambient = (lightCol.a*sunElevation)*(-NdotL*0.45+0.9)*lightCol.rgb + (skyLight*skyIntensity)*vec3(0.65,0.7,1.)*40. + skyIntensityNight*vec3(0.09,0.1,0.15)/1.5;
	
		vec3 diffuseLight = direct + lmtexcoord.w*ambient + torch_lightmap*0.42*vec3(TORCH_R,TORCH_G,TORCH_B)*TORCH_AMOUNT + 0.001;

		vec3 color = diffuseLight*albedo;
		
			
		gl_FragData[0].rgb = color;
	}



}
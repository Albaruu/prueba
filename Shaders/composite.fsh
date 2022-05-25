#version 120
#extension GL_EXT_gpu_shader4 : enable

#define TONEMAP_ACES

const int noiseTextureResolution = 1;

const float ambientOcclusionLevel = 1.0;
const float	sunPathRotation	= -40.;	//[0. -5. -10. -15. -20. -25. -30. -35. -40. -45. -50. -55. -60. -70. -80. -90.]
	
const int shadowMapResolution = 1024; //[512 768 1024 1536 2048 3172 4096 8192]
const float shadowDistance = 90.0;		//draw distance of shadows
const float shadowDistanceRenderMul = 1.; 
const bool 	shadowHardwareFiltering0 = true;	
/*
const int colortex0Format = RGB8;
const int colortex1Format = R11F_G11F_B10F;
*/
//no need to clear the buffers, saves a few fps
const bool colortex0Clear = false;
const bool colortex1Clear = false;



varying vec2 texcoord;
varying float exposure;
uniform sampler2D depthtex0;
uniform sampler2D colortex1;

uniform vec3 nsunColor;
uniform vec3 sunVec;

uniform vec3 sunPosition;
uniform float skyIntensity;
uniform float skyIntensityNight;
uniform float fogAmount;
uniform float rainStrength;
uniform ivec2 eyeBrightness;
uniform float frameTimeCounter;

#include "lib/color_transforms.glsl"
#include "lib/color_dither.glsl"
#include "lib/projections.glsl"
#include "lib/sky_gradient.glsl"

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
/* DRAWBUFFERS:0 */
	vec3 color = texture2D(colortex1,texcoord).rgb/10.;
	
	
	float z = texture2D(depthtex0,texcoord).x;
	if (z < 1.0){

		vec3 fragpos = toScreenSpace(vec3(texcoord,z));
		float dist = length(fragpos);
		vec3 np3 = mat3(gbufferModelViewInverse) * (fragpos/(dist));
		vec3 skyColor = getSkyColor(np3,mat3(gbufferModelViewInverse)*sunVec,np3.y) ;

		float fogFactorAbs = exp(-dist*fogAmount*0.3);
		float fogFactorScat = exp(-dist*fogAmount*0.8);
		
		vec3 col0 = normalize(skyColor)*(skyIntensity*mix(vec3(1.),vec3(0.8,0.9,1.),rainStrength)+skyIntensityNight*0.01)*2.;
		vec3 fogColor = mix(col0,skyColor,clamp(dist/512.,0.,1.));
		
		color.rgb = fogColor*(1.0-fogFactorScat)*sqrt(eyeBrightness.y/255.0)+color*fogFactorAbs;
	
	}
	//vignetting
	color *= 15.0-dot(texcoord-0.5,texcoord-0.5)*20.;
	
	//tonemap
	#ifndef TONEMAP_ACES
		gl_FragData[0].rgb = int8Dither(Uncharted2Tonemap(exposure*color)/Uncharted2Tonemap(vec3(11.2)),texcoord);
	#endif
	#ifdef TONEMAP_ACES
		gl_FragData[0].rgb = int8Dither(ACESFilm(exposure*vec3(1.0,0.98,0.9)*color),texcoord);
	#endif

}
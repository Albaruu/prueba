#version 120
#extension GL_EXT_gpu_shader4 : enable
const float	sunPathRotation	= -40.;	//[0. -5. -10. -15. -20. -25. -30. -35. -40. -45. -50. -55. -60. -70. -80. -90.]
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec3 sunVec;

varying float sunIntensity;
varying float skyIntensity;
varying float moonIntensity;
varying float skyIntensityNight;

varying float SdotU;
varying vec3 skyLight;
uniform float texelSizeX;
uniform float texelSizeY;
uniform vec3 sunPosition;
uniform vec3 upPosition;
uniform int worldTime;

uniform float rainStrength;
uniform float wetness;
uniform ivec2 eyeBrightnessSmooth;
uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;
uniform vec3 cameraPosition;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	//correct celestial rotation, ported to glsl by builderboy
	const float sunRotation = radians(sunPathRotation); 
	const vec2 sunData = vec2(cos(sunRotation), -sin(sunRotation)); 

	float ang = fract(worldTime / 24000.0 - 0.25);
	ang = (ang + (cos(ang * 3.14159265358979) * -0.5 + 0.5 - ang) / 3.0) * 6.28318530717959;

	sunVec = normalize(vec3(-sin(ang), cos(ang) * sunData));
	float pi = 3.14159265359;
	float angSun= -(( pi * 0.5128205128205128 - acos(sunVec.y*1.065-0.065))/1.5);
	float angMoon= -(( pi * 0.5128205128205128 - acos(-sunVec.y*1.065-0.065))/1.5);
	float angSky= -(( pi * 0.5128205128205128 - acos(sunVec.y*0.95+0.05))/1.5);
	float angSkyNight= -(( pi * 0.5128205128205128 -acos(-sunVec.y*0.95+0.05))/1.5);
	
	sunIntensity=max(0.,1.0-exp(angSun));
	skyIntensity=max(0.,1.0-exp(angSky));
	moonIntensity=max(0.,1.0-exp(angMoon));
	skyIntensityNight=max(0.,1.0-exp(angSkyNight));

	

	gl_Position = ftransform();

}

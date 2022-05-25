#version 120
#extension GL_EXT_gpu_shader4 : enable
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec4 lmtexcoord;
varying vec4 color;
 varying vec4 normalMat;
varying vec3 binormal;
varying vec3 tangent;
uniform mat4 gbufferModelViewInverse;

attribute vec4 at_tangent;
attribute vec4 mc_Entity;

#define SHADOW_MAP_BIAS 0.8



//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	lmtexcoord.xy = (gl_MultiTexCoord0).xy;
	vec2 lmcoord = gl_MultiTexCoord1.xy/255.;
	lmtexcoord.zw = lmcoord*lmcoord;
	
	gl_Position = ftransform();
	color = gl_Color;
	float mat = 0.0;
	if(mc_Entity.x == 8.0 || mc_Entity.x == 9.0) mat = 1.0;
		

	if(mc_Entity.x == 79.0) mat = 0.5;
	if (mc_Entity.x == 10002) mat = 0.5;
	normalMat = vec4(normalize( gl_NormalMatrix*gl_Normal),mat);		


	tangent = normalize( gl_NormalMatrix *at_tangent.rgb);
	binormal = normalize(cross(tangent.rgb,normalMat.xyz)*at_tangent.w);
	
	mat3 tbnMatrix = mat3(tangent.x, binormal.x, normalMat.x,
								  tangent.y, binormal.y, normalMat.y,
						     	  tangent.z, binormal.z, normalMat.z);
	

	

}
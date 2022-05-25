
float stars(vec3 fragpos){

	float elevation = clamp(fragpos.y,0.,1.);
	vec2 uv = fragpos.xz*inversesqrt(elevation);
	float noise  = texture2D(noisetex, uv).x;
	
	return clamp(noise-0.9,0.,1.)*elevation*(1.0*7. - rainStrength*0.999999*7.);
}
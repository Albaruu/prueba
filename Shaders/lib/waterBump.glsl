
vec3 getWaterBump(vec2 posxz, float waveM, float waveZ, float iswater){

posxz = posxz.yx/iswater/iswater/iswater/iswater;
float radiance = 0.1;

mat2 rotationMatrix = mat2(vec2(cos(radiance), -sin(radiance)),
					vec2(sin(radiance), cos(radiance)));
					
float radiance2 = -0.5;

mat2 rotationMatrix2 = mat2(vec2(cos(radiance2), -sin(radiance2)),
					vec2(sin(radiance2), cos(radiance2)));
	

	vec2 movement = vec2(0.0, frameTimeCounter * 0.00016*(iswater*2.-1.));
	
	vec2 coord0 = rotationMatrix2*(posxz* waveZ+ movement * waveM * 697.0);

	if (iswater > 0.9)coord0.y *= 4.;

	


	vec3 wave = texture2D(noisetex,coord0/300.).xyz*2.0-1.0;
	wave+=texture2D(noisetex,coord0/150.+ movement * waveM * 697.0/75.).xyz*2.0/2.-1.0/2.;
	wave+=texture2D(noisetex,coord0/75.).xyz*2.0/4.-1.0/4.;
	wave+=texture2D(noisetex,coord0/37.5).xyz*2.0/8.-1.0/8.;
	return wave/1.875;
	
}

vec3 getWaveHeight(vec2 posxz, float iswater){

	vec2 coord = posxz;

		float deltaPos = 0.1;
		
		float waveZ = mix(4.0,0.25,iswater);
		float waveM = mix(0.,2.0,iswater);
	


		vec3 wave = normalize(getWaterBump(coord, waveM, waveZ, iswater));

		return wave;
}
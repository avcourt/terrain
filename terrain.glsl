/*
* Author: Andrew Vaillancourt
*/

// CONSTANTS, try playing around with some values

// colors
const vec3 SKY_COL = vec3(0.76,0.94, 1.0);
const vec3 MTN_COL = vec3(0.4, 0.2, 0.0);
const vec3 ICE_COL = vec3(0.9, 0.9, 1.0);
const vec3 LIGHT_COL = vec3(0.95, 1.0, 0.89); // white, slightly yellow light

const float FOG_DENSITY = -0.04;
const float SKY = -1.0;                 // materialID for sky
const vec3 EPS = vec3(0.001, 0.0, 0.0); // smaller values = more detail when normalizing
const float MAX_DIST = 60.0;            // used when ray casting to limit ray length
const int RAYS = 30;                    // number of rays cast, set lower if framerate slows
const int FREQUENCY = 15;               // try lower values if framerate issues encountered

// the following are used in terrain function
const float START_HEIGHT = 0.4;
const float WEIGHT = 0.6;
const float MULT = 0.35;



// Simple 2d noise algorithm from http://shadertoy.wikia.com/wiki/Noise
// I tweaked a few values
float noise( vec2 p ) {
	vec2 f = fract(p);
	p = floor(p);
	float v = p.x+p.y*1000.0;
	vec4 r = vec4(v, v+1.0, v+1000.0, v+1001.0);
	r = fract(10000.0*sin(r*.001));
	f = f*f*(3.0-2.0*f);
	return 2.0*(mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y))-1.0;
}


//generate terrain using above noise algorithm
float terrain( vec2 p, int freq ) {	
	float h = START_HEIGHT; // height, start at higher than zero so there's not too much snow/ice
	float w = WEIGHT; 	// weight
	float m = MULT; 	// multiplier
	for (int i = 0; i < freq; i++) {
		h += w * noise((p * m)); // adjust height based on noise algorithm
		w *= 0.5;
		m *= 2.0;
	}
	return h;
}

// this function determines how to colour, based on y.pos 
// out of the 3 basics SKY, MTN, ICE, assigns -1.0, 0.0 or 1.0
vec2 map( vec3 pos, int octaves ) {
	
	float dMin = MAX_DIST;	// nearest intersection
	float d; 		// depth
	float materialID = SKY; // set default material id to sky
	
	// rocky terrain - MTN
	float h = terrain(pos.xz, octaves);
	d = pos.y - h;
	if (d < dMin) { 
		dMin = d;
		materialID = 0.0;
	}
	// ice -set IF-statement to false to remove ice
	if (true) {
        float s = 0.05;
		d = pos.y - s;	
		if (d<dMin) { 
			dMin = d;
			materialID = 1.0;
		}
	}
	return vec2(dMin, materialID);
}

// ray casting funciton. ro = ray origin, rd = ray direction
// returns materialID
vec2 castRay( vec3 ro, vec3 rd, int freq) {
	float dist = 0.0;   // distance
	float delta = 0.2;  // step
	float material = -1.0;
	for (int i = 0; i < RAYS; i++) {
		if (dist < MAX_DIST ) {	// ignore if 'sky'
			dist += delta; 		// next step
			vec2 result = map(ro + rd*dist, freq); // get intersection
			delta = result.x; 
			material = result.y; // set material id based on y pos
		} 
		else break; //ignore 'sky'
	}
	if (dist > MAX_DIST) material = SKY; // if nothing intersects set as sky
	return vec2(dist, material);
}

// calculates normal, try changing epsilon constant
vec3 calcNormal( vec3 p, int freq) {
	return normalize( vec3(map(p + EPS.xyy, freq).x - map(p-EPS.xyy, freq).x,
			       map(p+EPS.yxy, freq).x - map(p-EPS.yxy, freq).x,
			       map(p+EPS.yyx, freq).x - map(p-EPS.yyx, freq).x) );
}



vec3 render( vec3 ro, vec3 rd ) {
	const int freq = FREQUENCY;
	
	vec3 color = SKY_COL; // base color is sky color
	vec2 res = castRay(ro, rd, freq);
	
	vec3 lightPos = normalize( vec3(1.0, 0.9, 0.0) ); // light position
	
	vec3 pos = ro + rd*res.x; // world position
	
	// material  = sky
	if (res.y < -0.5) {
		color = SKY_COL;
		return color;
	}
	// now we can calculate normals for moutnains and ice
    vec3 normal = calcNormal(pos, 10); 

	// material = MTN 
	if (res.y > -0.5 && res.y < 0.5 ) {	
        color = MTN_COL;	
		// add light
		float ambient = clamp( 0.5 + 0.5 * normal.y, 0.0, 1.0); // ambient
		float diffuse = clamp( dot( normal, lightPos ), 0.0, 5.0); // diffuse		
		color += (0.4 * ambient) * LIGHT_COL;
		color *= (1.9 * diffuse) * LIGHT_COL;	
	}
	// material = ICE
	if (res.y > 0.5) {
        color = ICE_COL;
			
		// add light
		float ambient = clamp( 0.5 + 0.5 * normal.y, 0.0, 1.0);     // ambient
		float diffuse = clamp( dot( normal, lightPos ), 0.0, 2.0);  // diffuse
	
		color += (0.3 * ambient) * LIGHT_COL;
		color *= (2.1 * diffuse) * LIGHT_COL;
	}
	
	// fog from http://in2gpu.com/2014/07/22/create-fog-shader/
	float fog = exp(FOG_DENSITY * res.x); 
	color = mix(vec3(0.3,0.3,0.35), color, fog); 
		
	return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {

	vec2 pos = 2.0 * ( fragCoord.xy / iResolution.xy ) - 1.0; // bound screen coords to [0, 1]
	pos.x *= iResolution.x / iResolution.y; // set aspect ratio

	// camera
	float x = 0.0 + (2.5*iTime);
	float y = 3.0;
    float z = 1.0;
	vec3 camPos = vec3(x, y, z); // set camera position
	
	const vec3 up = vec3(0.0, 1.0, 0.0); // up vector
	vec3 camLook = vec3(camPos.x + 1.0, y*0.8, 0.0); // lookAt vector
	
	
	vec3 w = normalize( camLook - camPos );
	vec3 u = normalize( cross(w, up) );
	vec3 v = normalize( cross(u, w) );
	
	vec3 rd = normalize( pos.x*u + pos.y*v + 2.0*w );
	
	// render
	vec3 color = render(camPos, rd);
	
	fragColor = vec4( color, 1.0 );
}

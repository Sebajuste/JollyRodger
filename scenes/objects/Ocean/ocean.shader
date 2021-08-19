shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx, blend_mix;

const float PI = 3.14159265358979323846;



uniform vec2 wave_a_direction = vec2(1.0, 1.0);
uniform float wave_a_steepness = 0.25;
uniform float wave_a_wavelength = 20.0;


uniform vec2 wave_b_direction = vec2(1.0, 0.6);
uniform float wave_b_steepness = 0.25;
uniform float wave_b_wavelength = 10.0;

uniform vec2 wave_c_direction = vec2(1.0, 1.3);
uniform float wave_c_steepness = 0.25;
uniform float wave_c_wavelength = 5.0;

uniform float ocean_time = 0.0;


// Surface settings:
uniform vec2 	sampler_scale 	 = vec2(0.25, 0.25); 			// Scale for the sampler
uniform vec2	sampler_direction= vec2(0.05, 0.04); 			// Direction and speed for the sampler offset

uniform sampler2D uv_sampler : hint_aniso; 						// UV motion sampler for shifting the normalmap
uniform vec2 	uv_sampler_scale = vec2(0.25, 0.25); 			// UV sampler scale
uniform float 	uv_sampler_strength = 0.04; 					// UV shifting strength

uniform sampler2D normalmap_a_sampler : hint_normal;			// Normalmap sampler A
uniform sampler2D normalmap_b_sampler : hint_normal;			// Normalmap sampler B

uniform sampler2D foam_sampler : hint_black;					// Foam sampler
uniform float 	foam_level 		 = 0.5;							// Foam level -> distance from the object (0.0 - 0.5)

// Volume settings:
uniform float 	refraction 		 = 0.075;						// Refraction of the water

uniform vec4 	color_deep : hint_color;						// Color for deep places in the water, medium to dark blue
uniform vec4 	color_shallow : hint_color;						// Color for lower places in the water, bright blue - green
uniform float 	beers_law		 = 2.0;							// Beers law value, regulates the blending size to the deep water level
uniform float 	depth_offset	 = -0.75;						// Offset for the blending

// Projector for the water caustics:
// uniform mat4	projector;										// Projector matrix, mostly the matric of the sun / directlight
uniform sampler2DArray caustic_sampler : hint_black;			// Caustic sampler, (Texture array with 16 Textures for the animation)



uniform float gerstner_height = 0.4;
uniform float gerstner_stretch = 1.0;



varying float vertex_height;
varying vec3 vertex_normal;
varying vec3 vertex_tangent;
varying vec3 vertex_binormal;

varying mat4 inv_mvp;						// Inverse ModelViewProjection matrix -> Needed for caustic projection





vec4 gerstnerWave(vec4 wave, vec3 p, inout vec3 tangent, inout vec3 binormal, float time) {
	
	float steepness = wave.z;
	float wavelength = wave.w;
	
	float k = 2.0 * PI / wavelength;
	float c = sqrt(9.8 / k);
	vec2 d = normalize(wave.xy);
	float f = k * (dot(d, p.xz) - c * time);
	float a = steepness / k;
	
	tangent += vec3(
		1.0-d.x * d.x * (steepness * sin(f)),
		d.x * (steepness * cos(f)),
		-d.x * d.y * (steepness * sin(f))
	);
	
	binormal += vec3(
		-d.x * d.y * (steepness * sin(f)),
		d.y * (steepness * cos(f)),
		1.0-d.y * d.y * (steepness * sin(f))
	);
	/*
	return vec4(
		0.0,
		a * sin(f),
		0.0,
		0.0
	);
	*/
	return vec4(
		d.x * (a * cos(f)) * gerstner_stretch,
		a * sin(f) * gerstner_height,
		d.y * (a * cos(f)) * gerstner_stretch,
		0.0
	);
	
}


float get_height(sampler2D tex, vec2 uv, float offset) {
	vec2 v1 = vec2(0.0, 1.0);
	vec2 v2 = vec2(0.866025, 0.5);
	vec2 v3 = vec2(0.866025, -0.5);
	
	float p1 = texture(tex, fract( uv + v1 * offset ) ).z;
	float p2 = texture(tex, fract( uv + v1 * -offset ) ).z;
	float p3 = texture(tex, fract( uv + v2 * offset ) ).z;
	float p4 = texture(tex, fract( uv + v2 * -offset ) ).z;
	float p5 = texture(tex, fract( uv + v3 * offset ) ).z;
	float p6 = texture(tex, fract( uv + v3 * -offset ) ).z;
	
	highp float m = (p1 + p2 + p3 + p4 + p5 + p6) / 6.0;
	
	return m;
}


void vertex() {
	
	float time = ocean_time;
	
	if( ocean_time == 0.0) {
		time = TIME;
	}
	
	vec4 vertex = vec4(VERTEX, 1.0);
	vec3 vertex_position = (WORLD_MATRIX * vertex ).xyz;
	
	vertex_tangent = vec3(0.0, 0.0, 0.0);
	vertex_binormal = vec3(0.0, 0.0, 0.0);
	
	vec4 wave_a = vec4(wave_a_direction, wave_a_steepness, wave_a_wavelength);
	vec4 wave_b = vec4(wave_b_direction, wave_b_steepness, wave_b_wavelength);
	vec4 wave_c = vec4(wave_c_direction, wave_c_steepness, wave_c_wavelength);
	
	vertex += gerstnerWave(wave_a, vertex_position, vertex_tangent, vertex_binormal, time);
	vertex += gerstnerWave(wave_b, vertex_position, vertex_tangent, vertex_binormal, time);
	vertex += gerstnerWave(wave_c, vertex_position, vertex_tangent, vertex_binormal, time);
	
	vertex_height = (PROJECTION_MATRIX * MODELVIEW_MATRIX * vertex).z;
	
	TANGENT = vertex_tangent;
	BINORMAL = vertex_binormal;
	vertex_normal = normalize(cross(vertex_binormal, vertex_tangent));
	NORMAL = vertex_normal;
	
	UV = vertex_position.xz * sampler_scale;
	
	VERTEX = vertex.xyz;
	
	inv_mvp = WORLD_MATRIX * inverse( PROJECTION_MATRIX *  MODELVIEW_MATRIX );
	
	float camera_distance = length(CAMERA_MATRIX[3].xyz - (WORLD_MATRIX[3].xyz - VERTEX)) / 1000.0;
	COLOR[0] = camera_distance;
}


void fragment() {
	
	// Calculation of the UV with the UV motion sampler
	vec2	uv_offset 					 = sampler_direction * TIME;
	vec2 	uv_sampler_uv 				 = UV * uv_sampler_scale + uv_offset;
	vec2	uv_sampler_uv_offset 		 = uv_sampler_strength * texture(uv_sampler, uv_sampler_uv).rg * 2.0 - 1.0;
	vec2 	uv 							 = UV + uv_sampler_uv_offset;
	
	// Normalmap:
	vec3 	normalmap					 = texture(normalmap_a_sampler, uv - uv_offset*2.0).rgb * 0.75;		// 75 % sampler A
			normalmap 					+= texture(normalmap_b_sampler, uv + uv_offset).rgb * 0.25;			// 25 % sampler B
	
	// Refraction UV:
	vec3	ref_normalmap				 = normalmap * 2.0 - 1.0;
			ref_normalmap				 = normalize(vertex_tangent*ref_normalmap.x + vertex_binormal*ref_normalmap.y + vertex_normal*ref_normalmap.z);
	vec2 	ref_uv						 = SCREEN_UV + (ref_normalmap.xy * refraction) / vertex_height;
	
	// Ground depth:
	float 	depth_raw					 = texture(DEPTH_TEXTURE, ref_uv).r * 2.0 - 1.0;
	float	depth						 = PROJECTION_MATRIX[3][2] / (depth_raw + PROJECTION_MATRIX[2][2]);
			
	float 	depth_blend 				 = exp((depth+VERTEX.z + depth_offset) * -beers_law);
			depth_blend 				 = clamp(1.0-depth_blend, 0.0, 1.0);	
	float	depth_blend_pow				 = clamp(pow(depth_blend, 2.5), 0.0, 1.0);
	
	// Ground color:
	vec3 	screen_color 				 = textureLod(SCREEN_TEXTURE, ref_uv, depth_blend_pow * 2.5).rgb;
	
	vec3 	dye_color 					 = mix(color_shallow.rgb, color_deep.rgb, depth_blend_pow);
	vec3	color 						 = mix(screen_color*dye_color, dye_color*0.25, depth_blend_pow*0.5);
	
	// Caustic screen projection
	vec4 	caustic_screenPos 			 = vec4(ref_uv*2.0-1.0, depth_raw, 1.0);
	vec4 	caustic_localPos 			 = inv_mvp * caustic_screenPos;
			caustic_localPos			 = vec4(caustic_localPos.xyz/caustic_localPos.w, caustic_localPos.w);
	
	vec2 	caustic_Uv 					 = caustic_localPos.xz / vec2(1024.0) + 0.5;
	vec4	caustic_color				 = texture(caustic_sampler, vec3(caustic_Uv*300.0, mod(TIME*14.0, 16.0)));
	
			color 						*= 1.0 + pow(caustic_color.r, 1.50) * (1.0-depth_blend) * 6.0;
	
	// Foam:
	if(depth + VERTEX.z < foam_level && depth > vertex_height-0.1)
	{
		float foam_noise = clamp(pow(texture(foam_sampler, (uv*4.0) - uv_offset).r, 10.0)*40.0, 0.0, 0.2);
		float foam_mix = clamp(pow((1.0-(depth + VERTEX.z) + foam_noise), 8.0) * foam_noise * 0.4, 0.0, 1.0);
		color = mix(color, vec3(1.0), foam_mix);
	}
	
	ALBEDO = color;
	
	RIM = 0.2;
	SPECULAR = 0.2 + depth_blend_pow * 0.4;
	ROUGHNESS = 0.2;
	METALLIC = 0.0;
	
	NORMALMAP = normalmap;
	NORMALMAP_DEPTH = 1.25;
	
}

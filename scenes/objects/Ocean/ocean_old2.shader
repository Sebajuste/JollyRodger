shader_type spatial;
// render_mode diffuse_lambert;
// render_mode specular_schlick_ggx;
render_mode cull_back;

const float PI = 3.14159265358979323846;


uniform sampler2D water_color : hint_albedo;
uniform sampler2D vector_map : hint_black;
uniform float water_color_depth = 1.0;

/*
uniform float wave_height = 0.3;
uniform float wave_z_offset = -0.15;
uniform float amplitude = 1.0;
*/
uniform float beach_alpha_fadeout = 0.05;

uniform sampler2D bubble_albedo_map : hint_albedo;
uniform int bubble_tiling = 3;
uniform float bubble_ramp = 1.0;
uniform float bubble_amount = 1.0;

uniform float flow_blend_timing = 1.0;

/*
uniform vec2 direction = vec2(1.0, 0.0);
uniform float steepness : hint_range(0.0, 1.0) = 0.5;
uniform float wave_length = 10.0;
*/
uniform vec4 wave_a = vec4(1.0, 1.0, 0.25, 20.0);
uniform vec4 wave_b = vec4(1.0, 0.6, 0.25, 10);
uniform vec4 wave_c = vec4(1.0, 1.3, 0.25, 5);

/*
uniform float gerstner_tiling = 0.1;
uniform float gerstner_2_tiling = 0.31;
uniform vec2 gerstner_speed = vec2(0.011, 0.014);
uniform vec2 gerstner_2_speed = vec2(0.013, 0.008);
*/

uniform float ocean_time = 0.0;

varying float vertex_height;
varying vec3 vertex_normal;
varying vec3 vertex_tangent;
varying vec3 vertex_binormal;


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
	
	return vec4(
		0.0, // d.x * (a * cos(f)),
		a * sin(f),
		0.0, // d.y * (a * cos(f))
		0.0
	);
	
}



void vertex() {
	
	float time = ocean_time;
	if( ocean_time == 0.0) {
		time = TIME;
	}
	
	/*
	vec2 uv_gerstner = ( vec4(UV.x, UV.y, UV.y, 1.0) + WORLD_MATRIX[3] * 0.25 ).xz * gerstner_tiling + vec2(TIME * gerstner_speed.x, TIME * gerstner_speed.y);
	vec2 uv_gerstner_2 = uv_gerstner * gerstner_2_tiling + vec2(gerstner_2_speed.x * TIME, gerstner_2_speed.y * TIME);
	
	vec2 uv = fract( vec4(UV.x, UV.y, UV.y, 1.0) + WORLD_MATRIX[3] * 0.25 ).xz;
	
	float camera_distance = length(CAMERA_MATRIX[3].xyz - (WORLD_MATRIX[3].xyz - VERTEX)) / 1000.0;
	
	
	vec2 gerstner_normal_read = ( texture(gerstner_normal_map, uv_gerstner).xy - vec2(0.5, 0.5) ) * gerstner_height;
	vec2 gerstner_2_normal_read = ( texture(gerstner_normal_map, uv_gerstner_2).xy - vec2(0.5, 0.5) ) * gerstner_2_height;
	
	vec3 gerstner = vec3(-gerstner_normal_read.x * gerstner_stretch, (pow( texture(gerstner_height_map, uv_gerstner).x, 0.4545) - 0.5) * gerstner_height, gerstner_normal_read.y * gerstner_stretch);
	vec3 gerstner_2 = vec3(-gerstner_2_normal_read.x * gerstner_2_stretch, (pow( texture(gerstner_height_map, uv_gerstner_2).x, 0.4545) - 0.5) * gerstner_2_height, gerstner_2_normal_read.y * gerstner_2_stretch);
	
	
	float height = get_height(vector_map, uv, 0.007);
	
	VERTEX += ( vec3(0.0, height, 0.0)  + vec3(0.0, wave_z_offset, 0.0) ) * wave_height + gerstner + gerstner_2;
	COLOR[0] = camera_distance;
	*/
	
	/*
	mat4 pos_matrix = mat4(
		vec4(1.0, 0.0, 0.0, 0.0),
		vec4(0.0, 1.0, 0.0, 0.0),
		vec4(0.0, 0.0, 1.0, 0.0),
		vec4(VERTEX.x, VERTEX.y, VERTEX.z, 1.0)
	);
	
	vec3 gridPoint = (WORLD_MATRIX * pos_matrix)[3].xyz;
	*/
	vec4 vertex = vec4(VERTEX, 1.0);
	vec3 vertex_position = (WORLD_MATRIX * vertex ).xyz;
	
	
	vertex_tangent = vec3(1.0, 0.0, 0.0);
	vertex_binormal = vec3(0.0, 0.0, 1.0);
	
	
	
	// vec3 p = vertex_position;
	vertex += gerstnerWave(wave_a, vertex_position, vertex_tangent, vertex_binormal, time);
	vertex += gerstnerWave(wave_b, vertex_position, vertex_tangent, vertex_binormal, time);
	vertex += gerstnerWave(wave_c, vertex_position, vertex_tangent, vertex_binormal, time);
	
	
	/*
	float wave_length = 10.0;
	float amplitude = 1.0;
	float k = 2.0 * PI / wave_length;
	vertex.y = amplitude * sin(k * (vertex_position.x - time ) );
	*/
	// height = p.y;
	vertex_position  = vertex.xyz;
	vertex_height = (PROJECTION_MATRIX * MODELVIEW_MATRIX * vertex).z;
	
	vec3 normal = normalize(cross(vertex_binormal, vertex_tangent));
	
	VERTEX = vertex.xyz;
	UV = vertex.xz; // * sampler_scale;
	TANGENT = vertex_tangent;
	BINORMAL = vertex_binormal;
	vertex_normal = normalize(cross(vertex_binormal, vertex_tangent));
	NORMAL = vertex_normal;
	
	float camera_distance = length(CAMERA_MATRIX[3].xyz - (WORLD_MATRIX[3].xyz - VERTEX)) / 1000.0;
	COLOR[0] = camera_distance;
}


void fragment() {
	/*
	ALBEDO = vec3(0.22, 0.32, 0.72);
	ROUGHNESS = 0.05;
	SPECULAR = 0.1;
	// ALPHA = 0.9;
	*/
	
	// UNDERWATER
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r; // LOOSING SS-REFLECTIONS
	
	// DEPTH REPROJECTION FROM CAMERA Z to Z Axis
	depth = depth * 2.0 - 1.0;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]); // Camera Z Depth to World Space Z
	depth = depth + VERTEX.z;
	
	// NORMAL APPLIED TO DEPTH AND READ FROM BUFFER AGAIN (DISTORTED Z-DEPTH)
	depth = texture(DEPTH_TEXTURE, SCREEN_UV + ((NORMAL.xy - vec2(0.5, 0.5)) * clamp(depth * 0.2, 0.0, 0.1) )).r;
	depth = depth * 2.0 - 1.0;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]); // Camera Z Depth to World Space Z
	depth = depth + VERTEX.z;
	
	// WATER COLOR GRADIENT
	vec3 water_gradient = texture(water_color, vec2(depth * water_color_depth, 0.5)).xyz;
	vec3 albedo_output = water_gradient;
	
	float alpha_output = smoothstep(depth, 0.00, beach_alpha_fadeout);
	
	// FLOW TIMING FOR FLOW MAPS (USED IN FOAM AND BUBBLES) 2 UVs BLENDED TOGETHER
	float flow_timing = TIME * flow_blend_timing;
	float flow_timing_a = fract(flow_timing);
	float flow_timing_b = fract(flow_timing + 0.5);
	
	// WATER DETAIL BUBBLES
	vec2 uv_detail_a = UV;
	vec3 albedo_bubbles_a = texture(bubble_albedo_map, uv_detail_a * vec2(float(bubble_tiling), float(bubble_tiling) ) ).xyz;
	// vec3 albedo_bubbles_b = texture(bubble_albedo_map, uv_detail_b * vec2(float(bubble_tiling), float(bubble_tiling) ) ).xyz;
	
	// USED FOR THE TWO SHIFTED FLOW MAPS TO BLEND BETWEEN EACH OTHER
	float time_mask = cos(flow_timing_a * 6.28318530718) / 2.0 + 0.5;
	
	// albedo_bubbles_a = mix(albedo_bubbles_a, albedo_bubbles_b, time_mask );
	
	float albedo_bubbles_mask = smoothstep(vertex_height, -0.0, bubble_ramp * 0.1);
	
	albedo_output = mix(
		albedo_output,
		albedo_output + albedo_bubbles_a,
		albedo_bubbles_mask * bubble_amount
		// albedo_bubbles_mask * bubble_amount + mask_beach_waves * 5.0 + height_gerstner.y * bubble_gerstner + height_gerstner_2.y * bubble_gerstner
	);
	
	ALBEDO = clamp(albedo_output, vec3(0.0, 0.0, 0.0), vec3(1.0, 1.0, 1.0));
	
	
	
	ALPHA = alpha_output;
	RIM = 0.2;
	SPECULAR = 0.1;
	ROUGHNESS = 0.05;
	METALLIC = 0.0;
	
	
}

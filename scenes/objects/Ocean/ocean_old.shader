shader_type spatial;
render_mode diffuse_lambert;
render_mode specular_schlick_ggx;

const float PI = 3.14159265358979323846;


uniform sampler2D water_color : hint_albedo;
uniform float water_color_depth = 1.0;

uniform float amplitude = 1.0;

uniform float beach_alpha_fadeout = 0.05;

/*
uniform vec2 direction = vec2(1.0, 0.0);
uniform float steepness : hint_range(0.0, 1.0) = 0.5;
uniform float wave_length = 10.0;
*/
uniform vec4 wave_a = vec4(1.0, 1.0, 0.25, 60.0);
uniform vec4 wave_b = vec4(1.0, 0.6, 0.25, 31);
uniform vec4 wave_c = vec4(1.0, 1.3, 0.25, 18);


uniform float ocean_time = 0.0;

vec3 gerstnerWave(vec4 wave, vec3 p, inout vec3 tangent, inout vec3 binormal, float time) {
	
	float steepness = wave.z;
	float wavelength = wave.w;
	float k = 2.0 * PI / wavelength;
	float c = sqrt(2.0 / k);
	vec2 d = normalize(wave.xy);
	float f = k * (dot(d, p.xz) - c * time);
	float a = steepness / k;
			
			//p.x += d.x * (a * cos(f));
			//p.y = a * sin(f);
			//p.z += d.y * (a * cos(f));
	tangent += vec3(
		-d.x * d.x * (steepness * sin(f)),
		d.x * (steepness * cos(f)),
		-d.x * d.y * (steepness * sin(f))
	);
	binormal += vec3(
		-d.x * d.y * (steepness * sin(f)),
		d.y * (steepness * cos(f)),
		-d.y * d.y * (steepness * sin(f))
	);
	return vec3(
		d.x * (a * cos(f)),
		a * sin(f),
		d.y * (a * cos(f))
	);
	
}

void vertex() {
	
	
	
	/*
	vec3 p = VERTEX;
	float k = 2.0 * PI / wave_length;
	float c = sqrt(1.0 / k);
	vec2 d = normalize(direction);
	float f = k * (dot(d, p.xz) - c * TIME);
	float a = steepness / k;
	
	p.x += d.x * (a * cos(f));
	p.y = a * sin(f);
	p.z += d.y * (a * cos(f));
	
	
	vec3 tangent = normalize(vec3(
		1.0 - d.x * d.x * (steepness * sin(f)),
		d.x * (steepness * cos(f)),
		-d.x * d.y * (steepness * sin(f))
	));
	vec3 binormal = vec3(
		-d.x * d.y * (steepness * sin(f)),
		d.y * (steepness * cos(f)),
		1.0 - d.y * d.y * (steepness * sin(f))
	);
	*/
	
	float time = ocean_time;
	if( ocean_time == 0.0) {
		// time = TIME;
	}
	
	vec3 gridPoint = VERTEX.xyz;
	vec3 tangent = vec3(1, 0, 0);
	vec3 binormal = vec3(0, 0, 1);
	vec3 p = gridPoint;
	p += gerstnerWave(wave_a, gridPoint, tangent, binormal, time);
	p += gerstnerWave(wave_b, gridPoint, tangent, binormal, time);
	p += gerstnerWave(wave_c, gridPoint, tangent, binormal, time);
	
	vec3 normal = normalize(cross(binormal, tangent));
	
	VERTEX = p;
	NORMAL = normal;
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
	
	ALBEDO = clamp(albedo_output, vec3(0.0, 0.0, 0.0), vec3(1.0, 1.0, 1.0));
	
	
	RIM = 0.2;
	SPECULAR = 0.6;
	ROUGHNESS = 0.08;
	METALLIC = 0.0;
	ALPHA = alpha_output;
}

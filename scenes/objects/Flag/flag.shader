shader_type spatial;
render_mode cull_disabled;


uniform sampler2D albedo_texture : hint_black;

uniform sampler2D uv_offset_texture : hint_black;
uniform vec2 uv_offset_scale = vec2(-0.2, -0.1);

uniform float face_distortion = 0.5;
uniform vec2 time_scale = vec2(0.1, 0.0);

void vertex()
{
	vec2 base_uv_offset = UV * uv_offset_scale  + TIME * time_scale;
	float noise = texture(uv_offset_texture, base_uv_offset).r;
	
	float texture_based_offset = (noise * 2.0 - 1.0) * UV.x;
	
	VERTEX.y += texture_based_offset;
	VERTEX.z += texture_based_offset * face_distortion;
	VERTEX.x += texture_based_offset * -face_distortion;
}


void fragment()
{
	ALBEDO = texture(albedo_texture, UV).rgb;
	
	METALLIC = 1.0;
	ROUGHNESS = 1.0;
	
}
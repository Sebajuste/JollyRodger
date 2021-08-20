shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform sampler2D uv_offset_texture : hint_black;
uniform vec2 uv_offset_scale = vec2(-0.2, -0.1);

uniform float face_distortion = 0.5;
uniform vec2 time_scale = vec2(0.1, 0.0);

void vertex() {
	// UV=UV*uv1_scale.xy+uv1_offset.xy;
	vec2 base_uv_offset = UV * uv_offset_scale  + TIME * time_scale;
	float noise = texture(uv_offset_texture, base_uv_offset).r;
	
	float texture_based_offset = (noise * 2.0 - 1.0) * UV.x;
	
	VERTEX.y += texture_based_offset;
	VERTEX.z += texture_based_offset * face_distortion;
	VERTEX.x += texture_based_offset * -face_distortion;
}




void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
}

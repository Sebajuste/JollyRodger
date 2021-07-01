shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform sampler2D texture_grass : hint_albedo;
uniform sampler2D texture_rock : hint_albedo;
uniform float specular : hint_range(0,1);
uniform float metallic : hint_range(0,1);
uniform float roughness : hint_range(0,1);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
varying vec3 uv2_triplanar_pos;
uniform float uv2_blend_sharpness;
varying vec3 uv2_power_normal;



varying flat vec3 out_color;
varying vec3 vertex_norm;
varying vec3 vertex_pos;


void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	vertex_pos = VERTEX;
	vertex_norm = normalize(NORMAL);
	
	TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.y);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);
	BINORMAL = vec3(0.0,-1.0,0.0) * abs(NORMAL.x);
	BINORMAL+= vec3(0.0,0.0,1.0) * abs(NORMAL.y);
	BINORMAL+= vec3(0.0,-1.0,0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);
	uv2_power_normal = pow(abs(NORMAL),vec3(uv2_blend_sharpness));
	uv2_power_normal /= dot(uv2_power_normal, vec3(1.0));
	uv2_triplanar_pos = VERTEX * uv2_scale + uv2_offset;
	uv2_triplanar_pos *= vec3(1.0,-1.0, 1.0);
}

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp=vec4(0.0);
	samp+= texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp+= texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp+= texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}

void fragment() {
	
	vec2 base_uv = UV;
	
	vec4 albedo_tex = texture(texture_grass, base_uv);

	vec4 rock_tex = triplanar_texture(texture_rock, uv2_power_normal, uv2_triplanar_pos);
	vec4 cliff_mixed = mix(rock_tex, albedo_tex, pow( vertex_norm.y, 5));
	albedo_tex = mix(albedo_tex, cliff_mixed, min(vertex_pos.y / 0.7f, 1));
	
	ALBEDO = albedo_tex.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
}

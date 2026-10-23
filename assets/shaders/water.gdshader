shader_type spatial;
render_mode alpha_to_coverage, cull_disabled, depth_draw_opaque;

uniform sampler2D normal_map : hint_default_normal;
uniform sampler2D noise_texture : hint_default_white;
uniform vec4 deep_color : source_color = vec4(0.02, 0.08, 0.15, 0.85);
uniform vec4 shallow_color : source_color = vec4(0.1, 0.25, 0.35, 0.7);
uniform vec4 foam_color : source_color = vec4(0.4, 0.35, 0.3, 0.6);
uniform float wave_speed = 0.8;
uniform float wave_scale = 0.6;
uniform float foam_threshold = 0.65;
uniform float distortion_strength = 0.08;
uniform float fresnel_power = 3.5;
uniform float transparency = 0.7;

varying vec2 world_uv;

void vertex() {
	world_uv = VERTEX.xz * 0.05;
	
	float t = TIME * wave_speed;
	vec2 uv1 = world_uv + vec2(t * 0.3, t * 0.2);
	vec2 uv2 = world_uv * 2.0 - vec2(t * 0.15, t * 0.25);
	vec2 uv3 = world_uv * 0.5 + vec2(t * 0.5, t * 0.4);
	
	float wave1 = texture(noise_texture, uv1).r * 0.5;
	float wave2 = texture(noise_texture, uv2).r * 0.3;
	float wave3 = texture(noise_texture, uv3).r * 0.15;
	
	float height = (wave1 + wave2 + wave3) * wave_scale;
	
	VERTEX.y += height;
	
	NORMAL = normalize(vec3(
		texture(noise_texture, uv1 + vec2(0.01, 0.0)).r - texture(noise_texture, uv1 - vec2(0.01, 0.0)).r,
		2.0,
		texture(noise_texture, uv1 + vec2(0.0, 0.01)).r - texture(noise_texture, uv1 - vec2(0.0, 0.01)).r
	));
	
	UV = world_uv;
}

void fragment() {
	vec3 view_dir = normalize(-VIEW);
	vec3 normal = normalize(NORMALMAP);
	
	float depth_factor = smoothstep(0.0, 5.0, VERTEX.y + 2.0);
	vec4 water_color = mix(shallow_color, deep_color, depth_factor);
	
	float foam = smoothstep(foam_threshold, 1.0, texture(noise_texture, world_uv * 3.0 + TIME * 2.0).r);
	
	float fresnel = pow(1.0 - max(dot(view_dir, normal), 0.0), fresnel_power);
	
	vec3 final_color = mix(water_color.rgb, foam_color.rgb, foam);
	final_color += vec3(fresnel * 0.3) * (1.0 - foam);
	
	ALBEDO = final_color;
	ALPHA = transparency * (1.0 - foam * 0.5);
	
	METALLIC = 0.0;
	ROUGHNESS = 0.1;
	SPECULAR = 0.9;
	
	if (foam > 0.5) {
		ROUGHNESS = 0.8;
		SPECULAR = 0.2;
	}
}
shader_type spatial;
render_mode unshaded;

uniform sampler2D height_noise : hint_default_white;
uniform sampler2D detail_noise : hint_default_white;
uniform vec4 sand_color : source_color = vec4(0.75, 0.68, 0.55, 1.0);
uniform vec4 wet_sand_color : source_color = vec4(0.45, 0.4, 0.32, 1.0);
uniform vec4 rock_color : source_color = vec4(0.3, 0.28, 0.25, 1.0);
uniform vec4 grass_color : source_color = vec4(0.2, 0.35, 0.15, 1.0);
uniform float sand_rock_blend = 0.3;
uniform float grass_threshold = 0.6;
uniform float detail_scale = 15.0;
uniform float macro_scale = 0.02;
uniform float time_speed = 0.1;

varying float height_blend;
varying vec2 detail_uv;

void vertex() {
	detail_uv = VERTEX.xz * detail_scale * 0.01;
	height_blend = texture(height_noise, VERTEX.xz * macro_scale).r;
}

void fragment() {
	vec2 uv = UV;
	vec2 detail = detail_uv + TIME * time_speed * 0.05;
	
	float macro = height_blend;
	float detail_n = texture(detail_noise, detail).r;
	
	float sand_mask = smoothstep(sand_rock_blend - 0.15, sand_rock_blend + 0.15, macro);
	float grass_mask = smoothstep(grass_threshold - 0.1, grass_threshold + 0.1, macro);
	
	vec3 col = mix(sand_color.rgb, wet_sand_color.rgb, clamp((0.35 - macro) * 3.0, 0.0, 1.0));
	col = mix(col, rock_color.rgb, sand_mask);
	col = mix(col, grass_color.rgb, grass_mask * (1.0 - sand_mask));
	
	float detail_mult = 1.0 + (detail_n - 0.5) * 0.1;
	col *= detail_mult;
	
	ALBEDO = col;
	ROUGHNESS = mix(0.9, 0.7, sand_mask);
	ROUGHNESS = mix(ROUGHNESS, 0.95, grass_mask);
}
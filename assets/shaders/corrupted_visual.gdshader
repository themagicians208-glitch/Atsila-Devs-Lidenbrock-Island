shader_type spatial;
render_mode unshaded, depth_draw_never;

uniform sampler2D noise_texture : hint_default_white;
uniform float corruption_strength : hint_range(0.0, 1.0) = 0.3;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.15;
uniform float chromatic_aberration : hint_range(0.0, 0.05) = 0.008;
uniform float glitch_speed : hint_range(0.1, 5.0) = 1.2;
uniform vec4 corruption_color : source_color = vec4(0.15, 0.05, 0.25, 1.0);
uniform bool affect_albedo = true;

varying vec2 uv_world;

void vertex() {
	uv_world = (VERTEX.xz * 0.1) + (TIME * 0.05);
}

void fragment() {
	vec2 uv = UV;
	vec2 uv_distorted = uv;
	
	float noise = texture(noise_texture, uv_world * 0.5 + TIME * glitch_speed * 0.1).r;
	
	float glitch_wave = sin(UV.y * 80.0 + TIME * glitch_speed * 3.0) * 0.002 * corruption_strength;
	uv_distorted.x += glitch_wave + noise * 0.01 * corruption_strength;
	
	float scanlines = sin(UV.y * 600.0 + TIME * 10.0) * scanline_intensity;
	
	vec3 base_color = corruption_color.rgb;
	
	if (affect_albedo) {
		ALBEDO = base_color * (1.0 + scanlines);
	} else {
		ALBEDO = vec3(0.0);
	}
	
	float alpha = corruption_strength * (0.3 + noise * 0.4) * (1.0 + scanlines * 2.0);
	ALPHA = alpha;
	
	float aberration = chromatic_aberration * corruption_strength * noise;
	ALBEDO.r += aberration;
	ALBEDO.b -= aberration;
	
	EMISSION = base_color * corruption_strength * 0.15 * noise;
}
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float distortion : hint_range(0.0, 0.08) = 0.018;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.32;
uniform float noise_strength : hint_range(0.0, 0.1) = 0.018;
uniform float scanline_strength : hint_range(0.0, 0.1) = 0.012;
uniform float chroma_amount : hint_range(0.0, 0.01) = 0.0012;
uniform float jitter_strength : hint_range(0.0, 0.01) = 0.0009;

float hash(vec2 value) {
	return fract(sin(dot(value, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 centered = uv * 2.0 - 1.0;
	float radius = dot(centered, centered);
	vec2 distorted_uv = uv + centered * radius * distortion;
	float band_time = floor(TIME * 18.0);
	float jitter = (hash(vec2(band_time, 4.0)) - 0.5) * jitter_strength;
	distorted_uv.x += jitter;

	vec2 red_uv = distorted_uv + vec2(chroma_amount, 0.0);
	vec2 blue_uv = distorted_uv - vec2(chroma_amount, 0.0);

	vec3 color = vec3(
		texture(screen_texture, red_uv).r,
		texture(screen_texture, distorted_uv).g,
		texture(screen_texture, blue_uv).b
	);

	float noise = hash(floor(uv * vec2(960.0, 540.0)) + vec2(band_time, band_time * 0.37)) - 0.5;
	color += noise * noise_strength;

	float scanline = sin((uv.y + TIME * 0.35) * 900.0) * scanline_strength;
	color -= scanline;

	float vignette = smoothstep(0.42, 1.08, length(centered));
	color *= 1.0 - vignette * vignette_strength;

	COLOR = vec4(color, 1.0);
}

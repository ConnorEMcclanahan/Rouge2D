shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D noise_tex : repeat_enable;

void fragment() {
	// blocky pixel dissolve: quantize the uv, then threshold noise
	vec2 blocks = vec2(64.0, 36.0);
	vec2 q = floor(UV * blocks) / blocks;
	float n = texture(noise_tex, q).r;
	float reveal = step(n, progress);
	COLOR = vec4(0.03, 0.02, 0.01, 1.0 - reveal);
}

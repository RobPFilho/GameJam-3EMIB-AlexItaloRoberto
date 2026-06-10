shader_type canvas_item;

uniform float flame_strength = 0.05;
uniform float speed = 1.5;
uniform float pixel_size : hint_range(4.0, 128.0) = 24.0;

uniform vec4 tint : source_color = vec4(0.5, 0.8, 1.5, 1.0);

float hash(vec2 p)
{
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment()
{
	vec2 uv = UV;

	// Pixelated noise coordinates
	vec2 noise_uv = floor(uv * pixel_size);

	float n =
		hash(noise_uv + vec2(0.0, floor(TIME * speed * 8.0))) * 0.5 +
		hash(noise_uv * 0.5 + vec2(17.0, floor(TIME * speed * 5.0))) * 0.5;

	// Stronger distortion near edges
	float edge = abs(uv.x - 0.5) * 2.0;

	uv.x += (n - 0.5) * flame_strength * edge;

	// Rising flame motion
	uv.y -= TIME * speed * 0.05;

	vec4 tex = texture(TEXTURE, uv);

	// Edge burning effect
	float burn =
		smoothstep(0.2, 1.0, n + (1.0 - UV.y) * 0.5);

	tex.rgb *= tint.rgb;
	tex.rgb *= 0.8 + burn * 0.6;

	COLOR = tex;
}
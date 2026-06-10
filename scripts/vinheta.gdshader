shader_type canvas_item;

uniform float vignette_strength : hint_range(0.0, 2.0) = 1.2;
uniform float pixel_size : hint_range(4.0, 128.0) = 32.0;
uniform float warp_strength : hint_range(0.0, 0.2) = 0.04;
uniform float speed : hint_range(0.0, 5.0) = 1.0;

uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Controlled from GDScript
uniform float opacity : hint_range(0.0, 1.0) = 0.0;

float hash(vec2 p)
{
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.23);
	return fract(p.x * p.y);
}

void fragment()
{
	vec2 uv = UV;

	vec2 pix_uv = floor(uv * pixel_size) / pixel_size;

	float noise = hash(
		pix_uv +
		vec2(
			floor(TIME * speed * 2.0),
			floor(TIME * speed * 1.5)
		)
	);

	vec2 center = vec2(0.5, 0.5);
	vec2 offset = uv - center;

	offset.x += sin(offset.y * 15.0 + TIME * speed * 2.0)
		* warp_strength * noise;

	offset.y += cos(offset.x * 15.0 + TIME * speed * 1.7)
		* warp_strength * noise;

	float dist = length(offset);

	float vignette = smoothstep(
		0.35,
		0.75,
		dist * vignette_strength
	);

	float breakup = smoothstep(
		0.45,
		0.85,
		dist + noise * 0.15
	);

	float alpha = vignette * breakup * opacity;

	COLOR = vec4(
		vignette_color.rgb,
		alpha * vignette_color.a
	);
}
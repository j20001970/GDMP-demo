shader_type canvas_item;

const mat3 yuv2rgb_bt709 = mat3(
	vec3(1.00000, 1.00000, 1.00000),
	vec3(0.00000, -0.21482, 2.12798),
	vec3(1.28033, -0.38059, 0.00000)
);

uniform sampler2D texture_yuy2;

void fragment() {
	float y = texture(texture_yuy2, UV).r;
	float u;
	float v;
	if (mod(FRAGCOORD.x, 2.0) < 1.0) {
		u = texture(texture_yuy2, UV).g;
		v = texture(texture_yuy2, (FRAGCOORD.xy + vec2(1.0, 0)) * TEXTURE_PIXEL_SIZE).g;
	} else {
		u = texture(texture_yuy2, (FRAGCOORD.xy - vec2(1.0, 0)) * TEXTURE_PIXEL_SIZE).g;
		v = texture(texture_yuy2, UV).g;
	}
	u -= 0.5;
	v -= 0.5;
	vec3 rgb = yuv2rgb_bt709 * vec3(y, u, v);
	COLOR = vec4(rgb, 1.0);
}

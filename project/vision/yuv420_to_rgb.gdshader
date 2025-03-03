shader_type canvas_item;

const mat3 yuv2rgb_bt709 = mat3(
	vec3(1.00000, 1.00000, 1.00000),
	vec3(0.00000, -0.21482, 2.12798),
	vec3(1.28033, -0.38059, 0.00000)
);

uniform sampler2D texture_y;
uniform sampler2D texture_uv;

void fragment() {
	float y = texture(texture_y, UV).r;
	vec2 uv = texture(texture_uv, UV).rg - vec2(0.5, 0.5);
	vec3 rgb = yuv2rgb_bt709 * vec3(y, uv);
	COLOR = vec4(rgb, 1.0);
}

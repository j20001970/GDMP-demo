shader_type canvas_item;

const mat3 yuv2rgb_bt709 = mat3(
	vec3(1.00000, 1.00000, 1.00000),
	vec3(0.00000, -0.21482, 2.12798),
	vec3(1.28033, -0.38059, 0.00000)
);

uniform sampler2D texture_yuy2;

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE;
	vec2 UV_u = UV - floor(mod(UV / size, 2)) * vec2(1, 0) * size;
	vec2 UV_v = UV + (vec2(1, 0) - floor(mod(UV / size, 2))) * vec2(1, 0) * size;
	float y = texture(texture_yuy2, UV).r;
	float u = texture(texture_yuy2, UV_u).g;
	float v = texture(texture_yuy2, UV_v).g;
	vec3 rgb = yuv2rgb_bt709 * vec3(y, u - 0.5, v - 0.5);
	COLOR = vec4(rgb, 1.0);
}

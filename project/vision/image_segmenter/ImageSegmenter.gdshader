shader_type canvas_item;

uniform sampler2D mask;

void fragment() {
	float mask_color = texture(mask, UV).r;
	COLOR = mix(vec4(0, 1, 0, 1), COLOR, mask_color);
}

shader_type spatial;

uniform sampler2D character_texture : filter_nearest,source_color;

void fragment() {

	ALBEDO = texture(character_texture,UV).rgb;

}
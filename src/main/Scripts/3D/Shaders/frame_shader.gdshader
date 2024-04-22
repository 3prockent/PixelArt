shader_type spatial;

uniform sampler2D frame_texture : source_color ;

void fragment() {
	ALBEDO = texture(frame_texture,UV).rgb;
}

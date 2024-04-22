shader_type spatial;

//render_mode unshaded;

uniform sampler2D art_texture : filter_nearest,source_color;

void fragment() {

	ALBEDO = texture(art_texture,UV).rgb;

}



shader_type canvas_item;

uniform float num_lines = 20.;
uniform float transition_progress: hint_range(0.0, 1.0) = 0.0;
uniform vec4 line_color_a: source_color = vec4(0.467,0.314,0.639,1.0);
uniform vec4 line_color_b: source_color = vec4(0.353,0.298,0.42,1.0);

void fragment() {
	vec2 tiled_uv = vec2(fract(UV.x * num_lines / 2.), UV.y);
	if (tiled_uv.x < 0.5){
		if(tiled_uv.y < transition_progress){
			COLOR = line_color_a;
		} else {
			COLOR = vec4(0.0);
		}
	} else {
		if (tiled_uv.y > 1. - transition_progress){
			COLOR = line_color_b;
		} else {
			COLOR = vec4(0.0);
		}
	}
}
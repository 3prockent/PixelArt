shader_type canvas_item;

//two hint color grey and white, to show selected color
uniform vec4 displayed_selected_color : source_color = vec4(0.671,0.671,0.671,1.0);
uniform vec4 displayed_not_selected_color : source_color = vec4(1.0,1.0,1.0,1.0);

//two hint color green and red, to show if drawing tiles correct
uniform vec4 hint_color_drawing_process : source_color = vec4(0.0,1.0,0.0,1.0);

//color that will be contrast(selected)
uniform vec4 current_selected_color : source_color;

//ratio between showing lowcontrast image and selected color + white
uniform float ratio_to_zoomed_color = 0.0;

// image where search "current_selected_color", and select it
uniform sampler2D source_image : filter_nearest;

// image that stores current hinted pixels
uniform sampler2D bitmap_hint : filter_nearest;

// image stores white and black pixels, where white with diamond
// black - no
uniform sampler2D bitmap_progress : filter_nearest;

void fragment() {
	// color of currrent pixel on lowcontrast image
	vec4 lowcontrast_color = texture(TEXTURE, UV);
	
	// color of progress, if white - diamond setted, blsck - no
	vec4 progress_color = texture(bitmap_progress, UV);
	
	// color of currrent pixel on source image
	vec4 _source_color = texture(source_image, UV);
	
	// color of currrent pixel on hint image
	vec4 hint_color = texture(bitmap_hint, UV);
	
	// color that determines pixel on selected cell or not
	vec4 selected_or_not_color;
	
	//determines pixel on selected cell or not and set color to "selected_or_not_color"
	if (_source_color == current_selected_color){
		selected_or_not_color = displayed_selected_color;
	}
	else{
		selected_or_not_color = displayed_not_selected_color;
	}
	
	// mixin selected_or_not_color with basic lowcontrast source image, by ratio
	// than determines from zoom
	selected_or_not_color = mix(lowcontrast_color,selected_or_not_color,ratio_to_zoomed_color);
	if (progress_color == vec4(1.0,1.0,1.0,1.0)){
		selected_or_not_color = lowcontrast_color;
	}
	
	// final color that will seted after all checks
	vec4 final_color = selected_or_not_color;
	
	// check if current pixel on hinted cell, and mix it with proper hint color
	if (hint_color == vec4(1.0,1.0,1.0,1.0)){
		final_color = mix(selected_or_not_color,hint_color_drawing_process,0.5);
	}
	
	//setting final color to pixel
	COLOR = final_color;
}
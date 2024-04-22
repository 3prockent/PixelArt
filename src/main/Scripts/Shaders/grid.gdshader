shader_type canvas_item;

//image_size_in_pixels
uniform float number_of_cells;

//grid_width
uniform float grid_width = 1.0;

//image size
uniform float img_size;

// color of grid
uniform vec4 border_color : source_color;

// visibility(alpha) of top layer image, 0.0 when enter drawing by default
uniform float alpha;

// bitmap where white is seted pixels, black - empty (not drawen)
uniform sampler2D image_progress : filter_nearest;

//geting position for every procesing pixel(fragment),
//and store to variable
varying vec2 pixel_pos ;
void vertex(){
	pixel_pos = VERTEX; 
}
//____________________________________________________


void fragment() {
	// geting actuall pixel number between each cell (pixel,diamond) 
	float ratio = img_size/number_of_cells;
	
	// getting division_remainder(остача при діленні) for each pixel(each position)
	float division_remainder_x = mod(pixel_pos.x, ratio);
	float division_remainder_y = mod(pixel_pos.y, ratio);
	
	// getting color for current pixel from souce image (highres_with_numbers image)
	vec4 souce_image_color = texture(TEXTURE, UV);
	
	// var for store new color, for grid or number
	vec4 new_color_with_grid = souce_image_color;
	
	// if pixel(fragment) on grid, set to variable color of gridd
	if (division_remainder_x < grid_width || division_remainder_x>ratio-grid_width &&
	 division_remainder_x<ratio || division_remainder_y < grid_width ||
	 division_remainder_y>ratio-grid_width && division_remainder_y<ratio){
		new_color_with_grid = border_color;
	}
	
	// if pixel is not transparrent (space wetween grid and numbers.It is 
	// transparency around numbers)
	if (new_color_with_grid.a > 0.01){
		new_color_with_grid.a = alpha;
	}
	
	// get color of pixel, from bitmap (only black, and white)
	// check on witch cell(complete or non) is this pixel(cell)
	vec4 current_progress_color = texture(image_progress, UV);
	
	//check from bitmap, if diamond on this pixel, set it transparency for static
	// not affected by zoom
	if (current_progress_color == vec4(1.0,1.0,1.0,1.0)){
		new_color_with_grid.a = souce_image_color.a;
	}
	
	//returns color
	COLOR = new_color_with_grid;
}
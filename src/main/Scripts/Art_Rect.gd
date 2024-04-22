extends TextureRect

var ratio_imagesize_to_pixel : float
var actual_image_size : int

var current_cell_color : Color
var deffered_tiles : int = 0

var low_contrast_image : Image
var low_contrast_image_copy : Image = Image.new()
var low_contrast_tex : ImageTexture

var base_image : Image = Image.new()
var base_image_copy : Image = Image.new()
var base_imagetex : ImageTexture = ImageTexture.new()
var thread_with_high_res : Thread = Thread.new()

@onready var art : PixelArtTexture = ArtStorage.current_art_texture
@onready var image_size_in_pixels : int = int(art.get_size().x)
@onready var pallete_panel: PalletePanel = %Pallete_Panel
@onready var camera: Camera2D = %Camera2D
@onready var art_rect_top_layer: TextureRect = %Art_Rect_Top_Layer
@onready var source_img : Image = art.get_source_image()
@onready var numbers_with_colors : Dictionary = owner.color_number
@onready var move_draw_area : Control = %Input_handler

const cell_size : int = 50
const grid_border_multiply : float = 8.0
const max_zoom_reference : float = 2.0
const min_reference_size : float = 8.0

const offset_for_digit : Vector2i = Vector2(11,0)

const part_with_no_grid : float = 25.0
const part_with_rising_alpha : float = 2.0

const HINT_VIBRO_DURATION : int = 3
const SET_ONE_DIAMOND_VIBRO_DURATION : int = 5
const SET_SEVERAL_DIAMOND_VIBRO_DURATION : int = 20

var current_zoom : float
var no_grid : float
var rising_grid : float

var is_drawing_process : bool = false
var is_current_drawing_process_correct : bool:
	set(value):
		is_current_drawing_process_correct = value
		var hint_color_state : Color 
		if is_current_drawing_process_correct:
			hint_color_state = hint_color_true
		else:
			hint_color_state = hint_color_false
		material.set_shader_parameter("hint_color_drawing_process",hint_color_state)

var bitmap_hint : BitMap = BitMap.new()
var hint_imgtex : ImageTexture
var bitmap_progress : BitMap = BitMap.new()
var bitmap_progress_tex : ImageTexture
var bitmap_current_hint : BitMap = BitMap.new()

var current_selected_color : Color
var hint_color_true : Color = Color.GREEN
var hint_color_false : Color = Color.RED

var hint_saved_correct_pixels : Array[Vector2i]

const numbers : Array[String] = ["res://src/main/resources/assets/numbers/zero.png","res://src/main/resources/assets/numbers/one.png",
"res://src/main/resources/assets/numbers/two.png","res://src/main/resources/assets/numbers/three.png",
"res://src/main/resources/assets/numbers/four.png","res://src/main/resources/assets/numbers/five.png",
"res://src/main/resources/assets/numbers/six.png","res://src/main/resources/assets/numbers/seven.png",
"res://src/main/resources/assets/numbers/eight.png","res://src/main/resources/assets/numbers/nine.png"]

const DIAMOND_IMAGE : Image = preload("res://src/main/resources/assets/diamond/diamond_texture.png")

var all_numbers : Array 

func _ready() -> void:
	_connect_signals()
	create_array_with_image_numbers()
	create_low_contrast_image()
	set_zoom()
	_update_grid()
	create_thread_with_high_res()
	create_image_drawing_hint_bit()
	_set_start_shader_param()


func _connect_signals() -> void:
	pallete_panel.on_color_picked.connect(_on_new_color_picked)
	resized.connect(_on_resized)
	move_draw_area.pixelart_draw.connect(_on_pixelart_draw)
	move_draw_area.drawing_process_changed.connect(_on_drawing_process_changed)


func _process(delta: float) -> void:
	current_zoom = camera.zoom.x

	if current_zoom <= no_grid:
		art_rect_top_layer.material.set_shader_parameter("alpha",0.0)
		material.set_shader_parameter("ratio_to_zoomed_color",0.0)
	elif current_zoom <= rising_grid:
		var normilized_alpha : float = (current_zoom - no_grid) / (rising_grid - no_grid)
		art_rect_top_layer.material.set_shader_parameter("alpha",normilized_alpha)
		material.set_shader_parameter("ratio_to_zoomed_color",normilized_alpha)
	else:
		art_rect_top_layer.material.set_shader_parameter("alpha",1.0)
		material.set_shader_parameter("ratio_to_zoomed_color",1.0)


func create_image_drawing_hint_bit() -> void:
	bitmap_hint.create(Vector2i(image_size_in_pixels,image_size_in_pixels))
	bitmap_progress.create(Vector2i(image_size_in_pixels,image_size_in_pixels))
	bitmap_current_hint.create(Vector2i(image_size_in_pixels,image_size_in_pixels))


func is_pixel_free(pixel_pos : Vector2i) -> bool:
	return !bitmap_progress.get_bitv(pixel_pos)


func set_color_to_pixel(pixel_pos : Vector2i,deffer : bool) -> void:
	current_cell_color = source_img.get_pixelv(pixel_pos)
	#var full_rect : Rect2 = Rect2(0,0,cell_size,cell_size)
	var position_on_image : Vector2i = Vector2i(pixel_pos.x*cell_size,pixel_pos.y*cell_size)
	var img : Image
	var low_contrast_img : Image
	
	if deffer:
		img = base_image_copy
		low_contrast_img = low_contrast_image_copy
		deffered_tiles += 1
	else:
		img = base_image
		low_contrast_img = low_contrast_image
	
	## new 2 strokes that just delete number on cell
	var rect_of_cell : Rect2i = Rect2i(position_on_image, Vector2i(cell_size,cell_size))
	img.fill_rect(rect_of_cell, Color.TRANSPARENT)
	
	## old 1 stroke that blit diamond on number
	#img.blit_rect(DIAMOND_IMAGE,full_rect,position_on_image)
	
	low_contrast_img.set_pixelv(pixel_pos,current_cell_color)
	
	if !deffer:
		base_imagetex.update(img)
		low_contrast_tex.update(low_contrast_image)
		bitmap_progress.set_bitv(pixel_pos,true)
		bitmap_progress_tex.update(bitmap_progress.convert_to_image())
		owner.delete_tile_from_progres(current_cell_color,1)


func _on_pixelart_draw(global_pos:Vector2) -> void:
	var pixel_position : Vector2i = global_position_to_pixel(global_pos)
	if bitmap_current_hint.get_bitv(pixel_position) == true:
		return
	
	if is_pixel_free(pixel_position):
		if is_drawing_process:
			if is_current_drawing_process_correct:
				is_current_drawing_process_correct = is_selected_color_match_pixel(pixel_position)
				set_hint(is_current_drawing_process_correct,pixel_position)
			else:
				set_hint(false,pixel_position)
		elif is_selected_color_match_pixel(pixel_position):
			set_color_to_pixel(pixel_position,false)
			Input.vibrate_handheld(SET_ONE_DIAMOND_VIBRO_DURATION)
	elif is_drawing_process:
		is_current_drawing_process_correct = false
		set_hint(false,pixel_position)


func is_selected_color_match_pixel(pixel_pos : Vector2i) -> bool:
	return current_selected_color == source_img.get_pixelv(pixel_pos)


func set_hint(is_correct:bool, pixel_pos : Vector2i) -> void:
	var hint_color : bool
	if is_correct:
		hint_color = true
	else:
		hint_color = false
	bitmap_hint.set_bitv(pixel_pos,true)
	hint_imgtex.update(bitmap_hint.convert_to_image())
	Input.vibrate_handheld(HINT_VIBRO_DURATION)
	bitmap_current_hint.set_bitv(pixel_pos,true)
	if is_current_drawing_process_correct:
		set_color_to_pixel(pixel_pos,true)
		hint_saved_correct_pixels.append(pixel_pos)


func save_progress_from_array_to_bitmap() -> void:
	for pixels : Vector2i in hint_saved_correct_pixels:
		bitmap_progress.set_bitv(pixels,true)
	owner.delete_tile_from_progres(current_cell_color,deffered_tiles)
	bitmap_progress_tex.update(bitmap_progress.convert_to_image())


func restore_hint() -> void:
	bitmap_hint.set_bit_rect(Rect2i(Vector2i(0.0,0.0),bitmap_hint.get_size()),false)
	hint_imgtex.update(bitmap_hint.convert_to_image())


func make_copy_of_base_image() -> void:
	base_image_copy.copy_from(base_image)
	low_contrast_image_copy.copy_from(low_contrast_image)


func try_place_color_to_pixel() -> void:
	if is_current_drawing_process_correct:
		base_image.copy_from(base_image_copy)
		base_imagetex.update(base_image)
		low_contrast_image.copy_from(low_contrast_image_copy)
		low_contrast_tex.update(low_contrast_image)
		save_progress_from_array_to_bitmap()
		Input.vibrate_handheld(SET_SEVERAL_DIAMOND_VIBRO_DURATION)


func _on_drawing_process_changed(state : bool) -> void:
	is_drawing_process = state
	if is_drawing_process:
		is_current_drawing_process_correct = true
		make_copy_of_base_image()
	else:
		try_place_color_to_pixel()
		bitmap_current_hint.set_bit_rect(Rect2i(Vector2i(0,0),bitmap_current_hint.get_size()),false)
		hint_saved_correct_pixels.clear()
		deffered_tiles = 0
		restore_hint()


func global_position_to_pixel(global_pos:Vector2) -> Vector2i:
	var position_in_pixels : Vector2i
	var on_local_image_position : Vector2
	on_local_image_position = global_pos * get_global_transform()
	position_in_pixels = floor(on_local_image_position / ratio_imagesize_to_pixel)
	return position_in_pixels


func _set_start_shader_param() ->void:
	var source_imgtex : ImageTexture = ImageTexture.create_from_image(source_img)
	material.set_shader_parameter("source_image",source_imgtex)
	
	hint_imgtex = ImageTexture.create_from_image(bitmap_hint.convert_to_image())
	material.set_shader_parameter("bitmap_hint",hint_imgtex)
	
	bitmap_progress_tex = ImageTexture.create_from_image(bitmap_progress.convert_to_image()) 
	material.set_shader_parameter("bitmap_progress",bitmap_progress_tex)
	art_rect_top_layer.material.set_shader_parameter("image_progress",bitmap_progress_tex)


func create_array_with_image_numbers() -> void:
	for num in numbers.size():
		all_numbers.append(ResourceLoader.load(numbers[num]))


func create_thread_with_high_res() -> void:
	thread_with_high_res.start(set_highres_with_numbers)


func set_zoom() -> void:
	camera.zoom = Vector2(1.0,1.0)
	var image_multiply : float = image_size_in_pixels/min_reference_size
	var max_zoom : float = image_multiply*max_zoom_reference
	camera.max_zoom = Vector2(max_zoom,max_zoom)
	current_zoom = camera.zoom.x
	var zoom_part_in_work : float = max_zoom - current_zoom
	no_grid = zoom_part_in_work / part_with_no_grid + current_zoom
	rising_grid = zoom_part_in_work / part_with_rising_alpha + current_zoom


func _update_grid() -> void:
	art_rect_top_layer.material.set_shader_parameter("number_of_cells",float(image_size_in_pixels))
	art_rect_top_layer.material.set_shader_parameter("img_size",float(size.x))
	var border_width : float = grid_border_multiply / image_size_in_pixels
	art_rect_top_layer.material.set_shader_parameter("grid_width",float(border_width))


func set_highres_with_numbers() -> void:
	var time_enter_func : float = float(Time.get_ticks_msec()) 
	# creating High Resolution Image
	var image_size : int = image_size_in_pixels * cell_size
	base_image = Image.create(image_size,image_size,false,Image.FORMAT_RGBA8)
	for x in range(image_size_in_pixels):
		for y in range(image_size_in_pixels):
			var pixel_pos : Vector2 = Vector2(x,y)
			if source_img.get_pixelv(pixel_pos).a > General.ALPHA_THRESHOLD:
				set_number(pixel_pos)
			else :
				bitmap_progress.set_bitv(pixel_pos,true)
				bitmap_progress_tex.update(bitmap_progress.convert_to_image())
	base_imagetex = ImageTexture.create_from_image(base_image)
	art_rect_top_layer.call_deferred("set_texture",base_imagetex)
	var time_after_set : float = float(Time.get_ticks_msec()) 
	print("highres_img_created_in - ", (time_after_set-time_enter_func)/1000.0," seconds")
	


func set_number(pixel_position:Vector2i) -> void:
	var color_of_pixel : Color = source_img.get_pixelv(pixel_position)
	var number : String = str(numbers_with_colors[color_of_pixel])
	var digits_in_number : Array[String] = []
	for i in range(number.length()):
		digits_in_number.append(number[i])
	var full_rect : Rect2 = Rect2(0,0,cell_size,cell_size)
	var position_on_image : Vector2i = Vector2i(pixel_position.x*cell_size,pixel_position.y*cell_size)
	match  digits_in_number.size():
		1:
			var number_image : Image = all_numbers[int(digits_in_number[0])]
			base_image.blit_rect(number_image, full_rect,position_on_image)
		2:
			var first_digit : Image = all_numbers[int(digits_in_number[0])]
			var second_digit : Image = all_numbers[int(digits_in_number[1])]
			
			base_image.blend_rect(first_digit, full_rect,position_on_image-offset_for_digit)
			base_image.blend_rect(second_digit, full_rect,position_on_image+offset_for_digit)
			
		_:
			push_error("3-digit or more number, must be <= 99")


func create_low_contrast_image() -> void:
	var source_image : Image = Image.new()
	source_image.copy_from(art.get_source_image())
	low_contrast_image = PixelArtTexture.image_to_black_and_white(source_image,true)
	low_contrast_image.convert(Image.FORMAT_RGBA8)
	low_contrast_tex = ImageTexture.create_from_image(low_contrast_image)
	set_texture(low_contrast_tex)


func _on_new_color_picked()->void:
	current_selected_color = pallete_panel.get_current_selected_color()
	material.set_shader_parameter("current_selected_color",current_selected_color)


func _on_resized() -> void:
	_update_ratio()
	_update_grid()


func _update_ratio() -> void:
	image_size_in_pixels = int(art.get_size().x)
	actual_image_size = int(size.x)
	ratio_imagesize_to_pixel = float(actual_image_size) / float(image_size_in_pixels)


func _exit_tree() -> void:
	thread_with_high_res.wait_to_finish()

extends NinePatchRect

class_name PalletePanel

signal on_color_picked
signal color_pickers_over

@onready var pallete_container : HBoxContainer = %PalletteContainer
@onready var art_texture : PixelArtTexture = ArtStorage.current_art_texture
@onready var drawning : Drawning = owner
@onready var container_pallete_push: VBoxContainer = %container_pallete_push


var color_pickers : Array[ColorPick] = []
var selected_color_pick: ColorPick


func _ready():
	_create_palette()
	_connect_signals()


func _connect_signals():
	drawning.tile_drawen.connect(_on_tile_drawen)
	drawning.color_over.connect(_on_color_over)
	drawning.all_color_over.connect(_on_all_color_over)
	
	for color_pick:ColorPick in color_pickers:
		var connect_button = color_pick.color_picker_texture_button
		color_pick.color_picker_texture_button.pressed.connect(_on_master_clicked.bind(color_pick))


func _on_tile_drawen(color:Color,tile_count : int) -> void:
	if get_current_selected_color() == color:
		var one_tile_value : float = drawning.get_index_per_tile(color)
		var drawen_tiles_count : float = drawning.get_drawen_tiles(color)
		
		var final_color_progress_value : float = one_tile_value * drawen_tiles_count
		var colorpicker_progress_tween : Tween = get_tree().create_tween()
		colorpicker_progress_tween.tween_property(selected_color_pick,"color_progress",final_color_progress_value,1.0)
		
	else:
		push_error("unexpected color")


func _on_color_over(color:Color) -> void:
	if get_current_selected_color() == color:
		destroy_color_picker(selected_color_pick)
	else:
		push_error("unexpected color")


func _on_all_color_over() -> void:
	pass
	#SceneManager.change_scene_to(Constants.SCENES.MAIN_MENU,true)


func _on_master_clicked(color_pick : ColorPick):
	_set_selected_color_pick(color_pick)
	on_color_picked.emit()


func destroy_color_picker(color_pick : ColorPick) -> void:
	color_pick.animate_disappearance_and_free()
	color_pickers.erase(color_pick)
	if color_pickers.is_empty():
		color_pickers_over.emit()
		SceneManager.animate_and_free_scene(container_pallete_push,Vector2(0.0,300))
		return
	_set_selected_color_pick(color_pickers[0])
	on_color_picked.emit()


func get_current_selected_color() -> Color:
	var selected_color : Color = selected_color_pick.circle_color
	return selected_color


func _get_color_array_from_image(image:Image) -> Array[Color]:
	var unique_color:Array[Color]=[]
	for i in range(image.get_height()):
		for j in range(image.get_width()):
			var pixel_color : Color = image.get_pixel(i,j)
			if not unique_color.has(pixel_color):
				unique_color.append(pixel_color)
	return unique_color


func _create_palette():
	#get colors from source image:
	var pixel_art_colors : Dictionary = drawning.color_number
	#create single palette and add to palette container
	for i in pixel_art_colors.values():
		var color = pixel_art_colors.find_key(i)
		var color_picker_instance:ColorPick = Constants.SCENES.COLOR_PICKER.instantiate() as ColorPick
		color_picker_instance.amplitude = ColorPick.UNSELECTED_AMPLITUDE
		color_picker_instance.color_progress = drawning.get_color_progress_index(color)
		color_picker_instance.circle_color = color
		color_picker_instance.is_circle_selected = false
		color_picker_instance.color_number = i
		pallete_container.add_child(color_picker_instance)
		color_pickers.append(color_picker_instance)
	_set_selected_color_pick(color_pickers[0])
	on_color_picked.emit()


func _set_selected_color_pick(color_pick : ColorPick):
	if(selected_color_pick):
		selected_color_pick.is_circle_selected = false
	color_pick.is_circle_selected = true
	selected_color_pick = color_pick
		


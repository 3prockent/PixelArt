extends Camera2D

@onready var move_draw_area : Control = %Input_handler
@onready var art_rect : TextureRect = %Art_Rect
@onready var pallete_panel: PalletePanel = %Pallete_Panel


@export var min_zoom : Vector2 = Vector2(1.0,1.0)
@export var max_zoom : Vector2 = Vector2(5.0,5.0)

var center_of_viweport : Vector2
var viewport_half_x : float
var viewport_half_y : float
var left_limit : float
var right_limit : float
var top_limit : float
var bot_limit : float

var move_in_camera : Tween
const MOVE_IN_DURATION : float = 3.0

func _ready() -> void:
	connect_signals()
	set_camera_limits()
	set_camera_to_center_of_viewport()


func connect_signals() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	move_draw_area.one_finger_pan.connect(make_finger_pan)
	move_draw_area.two_finger_zoom.connect(make_zoom)
	move_draw_area.two_finger_pan.connect(make_finger_pan)
	art_rect.resized.connect(on_art_rect_resized)
	move_draw_area.zoom_with_wheel.connect(_on_zoom_with_wheel)
	General.current_scene_trans.end_trans.connect(_on_trans_end)
	pallete_panel.color_pickers_over.connect(_on_color_pickers_over)


func _on_color_pickers_over() -> void:
	call_deferred("animate_camera_zoom_out_to_the_center_of_art")


func _on_trans_end()->void:
	call_deferred("animate_camera_zoom_in_to_the_center_of_art")
	move_draw_area.gui_input.connect(func(event : InputEvent) ->void:
		move_in_camera.call_deferred("kill"),4)


func animate_camera_zoom_in_to_the_center_of_art() -> void:
	move_in_camera = get_tree().create_tween()
	move_in_camera.tween_property(self,"zoom",max_zoom,MOVE_IN_DURATION).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	move_in_camera.parallel().tween_property(self,"position",center_of_viweport,MOVE_IN_DURATION).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


func animate_camera_zoom_out_to_the_center_of_art() -> void:
	move_in_camera = get_tree().create_tween()
	move_in_camera.tween_property(self,"zoom",min_zoom,MOVE_IN_DURATION).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	move_in_camera.parallel().tween_property(self,"position",center_of_viweport,MOVE_IN_DURATION).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


func on_art_rect_resized() -> void:
	set_camera_limits()
	set_camera_to_center_of_viewport()


func _on_viewport_size_changed() -> void:
	set_camera_limits()
	set_camera_to_center_of_viewport()


func set_camera_to_center_of_viewport() -> void:
	global_position = center_of_viweport


func make_finger_pan(relative : Vector2) -> void:
	position -= relative / zoom
	set_camera_pos_to_limits()


func make_zoom(zoom_factor : float,start_zoom : Vector2, view_zoom_position : Vector2) -> void: 
	var previous_global_zoom_position : Vector2 = view_position_to_global(view_zoom_position)
	var new_zoom : Vector2 = start_zoom / zoom_factor
	zoom = new_zoom
	var diff : Vector2 = previous_global_zoom_position - view_position_to_global(view_zoom_position)
	position += diff
	clamp_zoom()
	set_camera_pos_to_limits()


func _on_zoom_with_wheel(zoom_factor : float,start_zoom : Vector2, view_zoom_position : Vector2) -> void:
	make_zoom(zoom_factor,start_zoom,view_zoom_position)
	set_camera_pos_to_limits()


func global_position_to_view(pos : Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * pos


func clamp_zoom() -> void:
	zoom = clamp(zoom, min_zoom, max_zoom)


func make_pan_two_fingers(between_fingers_pos_relative : Vector2) -> void:
	global_position -= between_fingers_pos_relative / zoom
	set_camera_pos_to_limits()


func set_camera_limits() -> void:
	viewport_half_x  = art_rect.size.x / 2.0
	viewport_half_y = art_rect.size.y / 2.0
	
	center_of_viweport = art_rect.get_global_rect().get_center()
	
	left_limit = center_of_viweport.x-viewport_half_x
	top_limit = center_of_viweport.y-viewport_half_y
	right_limit = center_of_viweport.x+viewport_half_x
	bot_limit = center_of_viweport.y+viewport_half_y


func view_position_to_global(pos : Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * pos


func set_camera_pos_to_limits() -> void:
	position = get_snap_in_limit_position()
	force_update_scroll()


func get_snap_in_limit_position() -> Vector2:
	var new_x : float = clamp(global_position.x, left_limit,right_limit)
	var new_y : float = clamp(global_position.y, top_limit,bot_limit)
	return Vector2(new_x,new_y)

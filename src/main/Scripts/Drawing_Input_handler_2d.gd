extends Control

signal pixelart_draw(global_pos : Vector2)
signal one_finger_pan(relative : Vector2)
signal two_finger_pan(between_fingers_pos_relative : Vector2)
signal two_finger_zoom(zoom_factor : float,start_zoom : Vector2,curr_pos_between_fingers : Vector2)
signal drawing_process_changed(state : bool)
signal pan_stoped
signal zoom_with_wheel(zoom_factor : float,start_zoom : Vector2,curr_pos_between_fingers : Vector2)

@onready var timer_to_draw : Timer = %Timer_to_draw
@onready var camera_2d : Camera2D = %Camera2D
@onready var art_rect : TextureRect = %Art_Rect
@onready var drawing : Drawning = owner

const ONE_FINGER : int = 1
const TWO_FINGER : int = 2
const HOLD_TIME_TO_DRAW : float = 0.3
const VIBRO_START_DRAW : int = 20
const ZOOM_POWER_WITH_WHEEL : float = 0.1
const MAX_HANDEL_FINGERS : int = 3


var finger_indexes_in_work_view : Dictionary
var fingers_blocked_to_pan : Array[int]
var drawing_finger_index : int = -1
var finger_can_draw : int = -1
var paning_finger_index : int = -1

var start_distance_between_fingers : float
var start_zoom : Vector2 
var start_between_pos : Vector2


func _ready() -> void:
	_connnect_signals()


func _connnect_signals() -> void:
	timer_to_draw.timeout.connect(make_finger_draw)
	gui_input.connect(_on_gui_input)
	drawing.all_color_over.connect(func() -> void: 
		gui_input.disconnect(_on_gui_input))


func _on_gui_input(event : InputEvent) -> void:
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)
		
	#Handle zooming with mouse wheel
	if event is InputEventMouseButton and event.is_pressed(): 
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: 
			start_zoom = camera_2d.zoom 
			zoom_with_wheel.emit(1.0 - ZOOM_POWER_WITH_WHEEL,start_zoom,get_global_mouse_position())
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: 
			start_zoom = camera_2d.zoom 
			zoom_with_wheel.emit(1.0 + ZOOM_POWER_WITH_WHEEL,start_zoom,get_global_mouse_position())


func handle_touch(event : InputEventScreenTouch) -> void:
	if finger_indexes_in_work_view.size() > MAX_HANDEL_FINGERS:
		return

	if event.is_pressed():
		finger_indexes_in_work_view[event.index] = event.position
		if is_touch_can_be_draw(event.index,event.position):
			finger_can_draw = event.index
			timer_to_draw.start(HOLD_TIME_TO_DRAW)
		elif finger_indexes_in_work_view.size() > ONE_FINGER:
			fingers_blocked_to_pan.append(event.index)
			restore_one_fingers_events()
			if finger_indexes_in_work_view.size() == TWO_FINGER:
				var fingers_positions : Array = finger_indexes_in_work_view.values()
				start_distance_between_fingers = fingers_positions[0].distance_to(fingers_positions[1])
				start_zoom = camera_2d.zoom
				start_between_pos = view_position_to_global(get_position_between_fingers(finger_indexes_in_work_view[0],finger_indexes_in_work_view[1])) 

	
	elif event.is_released():
		if is_event_tap(event.index):
			pixelart_draw.emit(local_control_position_to_global(event.position))
		if event.index in fingers_blocked_to_pan:
			fingers_blocked_to_pan.erase(event.index)
		finger_indexes_in_work_view.erase(event.index)
		restore_one_fingers_events()
		pan_stoped.emit()


func get_position_between_fingers(pos1:Vector2,pos2:Vector2) -> Vector2: 
	return (pos1+pos2)/2.0


func handle_drag(event : InputEventScreenDrag) -> void:
	if event.index not in finger_indexes_in_work_view:
		return
	
	if finger_indexes_in_work_view.size() == ONE_FINGER and event.index not in fingers_blocked_to_pan:
		if finger_drawing():
			if is_click_on_pixel_art(event.position):
				pixelart_draw.emit(local_control_position_to_global(event.position))
		elif finger_panning():
				one_finger_pan.emit(event.relative)
		else:
			paning_finger_index = event.index
			finger_can_draw = -1
			one_finger_pan.emit(event.relative)
			
	elif finger_indexes_in_work_view.size() == TWO_FINGER:
		finger_indexes_in_work_view[event.index] = event.position
		var finger_positions_view : Array = finger_indexes_in_work_view.values()
		var current_dist_between_fingers : float = finger_positions_view[0].distance_to(finger_positions_view[1])
		var zoom_factor : float = start_distance_between_fingers / current_dist_between_fingers 
		
		two_finger_zoom.emit(zoom_factor,start_zoom,global_to_view(start_between_pos))
		
		var position_between_fingers_current : Vector2 = get_position_between_fingers(finger_indexes_in_work_view[0],finger_indexes_in_work_view[1])
		var between_fingers_pos_relative : Vector2 = global_to_view(start_between_pos)   - position_between_fingers_current
		
		two_finger_pan.emit(-between_fingers_pos_relative)


func is_event_tap(event_index : int) -> bool:
	return event_index == finger_can_draw and finger_indexes_in_work_view.size() == ONE_FINGER


func restore_one_fingers_events() -> void:
	if drawing_finger_index != -1:
		drawing_finger_index = -1
		drawing_process_changed.emit(false)
	paning_finger_index = -1
	finger_can_draw = -1
	timer_to_draw.stop()


func finger_panning() -> bool:
	return paning_finger_index >= 0


func finger_drawing() -> bool:
	return drawing_finger_index >= 0


func make_finger_draw() -> void:
	if finger_can_draw != paning_finger_index and \
	finger_indexes_in_work_view.size() == ONE_FINGER and finger_can_draw >=0 :
		drawing_finger_index = finger_can_draw
		finger_can_draw = -1
		drawing_process_changed.emit(true)
		pixelart_draw.emit(local_control_position_to_global(finger_indexes_in_work_view[drawing_finger_index]))
		Input.vibrate_handheld(VIBRO_START_DRAW)


func is_touch_can_be_draw(touch_index : int, touch_position : Vector2) -> bool:
	var is_valid_touch_for_draw : bool = touch_index in finger_indexes_in_work_view and\
	finger_indexes_in_work_view.size() == ONE_FINGER
	return is_valid_touch_for_draw and is_click_on_pixel_art(touch_position)


func is_click_on_pixel_art(touch_position : Vector2) -> bool:
	var is_on_pixelart : bool
	var is_on_opaque_pixel : bool = false
	var pixelart_rect : Rect2 = art_rect.get_global_rect()
	var global_click_pos : Vector2 = local_control_position_to_global(touch_position)
	is_on_pixelart = pixelart_rect.has_point(global_click_pos)
	
	var pixel_position : Vector2i = art_rect.global_position_to_pixel(global_click_pos)
	if is_on_pixelart:
		var pixel_alpha : float = art_rect.source_img.get_pixelv(pixel_position).a
		is_on_opaque_pixel = pixel_alpha > General.ALPHA_THRESHOLD
	return is_on_pixelart and is_on_opaque_pixel


func view_position_to_global(pos : Vector2) -> Vector2:
	return camera_2d.get_canvas_transform().affine_inverse() * pos


func global_to_view(pos : Vector2) -> Vector2:
	return camera_2d.get_canvas_transform() * pos


func local_control_position_to_global(pos : Vector2) -> Vector2:
	return view_position_to_global(get_global_transform() * pos)

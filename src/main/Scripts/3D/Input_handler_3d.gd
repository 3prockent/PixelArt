extends Control

class_name Input_handler_3d

@onready var camera_marker : Marker3D = %camera_marker
@onready var main_3d_camera : Camera3D = %Main_3d_camera
@onready var timer_to_tap : Timer = %Timer_to_tap

const RAY_LENTH : float = 3000.0

const ONE_FINGER : int = 1
const TWO_FINGER : int = 2
const ZOOM_POWER_WITH_WHEEL : float = 0.1
const MAX_HANDEL_FINGERS : int = 3

var finger_indexes_in_work_2d : Dictionary
var finger_indexes_in_work_3d : Dictionary
var fingers_blocked_to_pan : Array[int]

var start_distance_between_fingers : float
var start_zoom : float

signal one_finger_pan(relative : Vector2)
signal two_finger_zoom(zoom_factor : float,start_zoom : float,curr_pos_between_fingers : Vector2)
signal two_finger_pan(relative_pan : Vector3)
signal finger_event_changed(started : bool)
signal zoom_with_wheel(zoom_factor : float,start_zoom : float,curr_pos_between_fingers : Vector2)
signal one_finger_tap(collider : Node3D)

func _gui_input(event : InputEvent) -> void:
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)
	#Handle zooming with mouse wheel
	if event is InputEventMouseButton and event.is_pressed(): 
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			start_zoom = camera_marker.zoom 
			zoom_with_wheel.emit(1.0 - ZOOM_POWER_WITH_WHEEL,start_zoom,get_global_mouse_position())
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			start_zoom = camera_marker.zoom 
			zoom_with_wheel.emit(1.0 + ZOOM_POWER_WITH_WHEEL,start_zoom,get_global_mouse_position())


func handle_touch(event : InputEventScreenTouch) -> void:
	if event.is_pressed() and finger_indexes_in_work_2d.size() < MAX_HANDEL_FINGERS :
		finger_indexes_in_work_2d[event.index] = event.position
		finger_indexes_in_work_3d[event.index] = view_position_to_3d(event.position,1)
		if finger_indexes_in_work_2d.size() == ONE_FINGER:
			timer_to_tap.start()
			finger_event_changed.emit(true)
		if finger_indexes_in_work_2d.size() == TWO_FINGER:
			var finger_positions : Array = finger_indexes_in_work_2d.values()
			start_distance_between_fingers = finger_positions[0].distance_to(finger_positions[1])
			start_zoom = camera_marker.zoom
			fingers_blocked_to_pan.append(event.index)
			timer_to_tap.stop()
	elif event.is_released():
		if is_finger_tap():
			one_finger_tap.emit(view_position_to_collider(event.position))
		timer_to_tap.stop()
		finger_indexes_in_work_2d.erase(event.index)
		finger_indexes_in_work_3d.erase(event.index)
		if event.index in fingers_blocked_to_pan:
			fingers_blocked_to_pan.erase(event.index)
		finger_event_changed.emit(false)


func view_position_to_collider(view_pos : Vector2) -> Node3D:
	var space_state: PhysicsDirectSpaceState3D = main_3d_camera.get_world_3d().direct_space_state
	var ray_from : Vector3 = main_3d_camera.project_ray_origin(view_pos)
	var ray_to : Vector3 = ray_from + main_3d_camera.project_ray_normal(view_pos) * RAY_LENTH
	var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_from,ray_to)
	var information_about_ray_collision : Dictionary = space_state.intersect_ray(query)
	if information_about_ray_collision.has("collider"):
		return information_about_ray_collision["collider"]
	push_error("finger dont collide any object")
	return null

func is_finger_tap() -> bool:
	return finger_indexes_in_work_2d.size() == ONE_FINGER and !timer_to_tap.is_stopped()


func handle_drag(event : InputEventScreenDrag) -> void:
	timer_to_tap.stop()
	if event.index not in finger_indexes_in_work_2d:
		return
	
	if finger_indexes_in_work_2d.size() == ONE_FINGER and event.index not in fingers_blocked_to_pan:
		var cur_3d_position : Vector3 = view_position_to_3d(event.position,1)
		var relative_3d : Vector3 = cur_3d_position - finger_indexes_in_work_3d[event.index]
		one_finger_pan.emit(relative_3d)
	elif finger_indexes_in_work_2d.size() == TWO_FINGER:
		var finger_positions_2d : Array = finger_indexes_in_work_2d.values()
		var current_dist_between_fingers : float = finger_positions_2d[0].distance_to(finger_positions_2d[1])
		var _zoom_factor : float = start_distance_between_fingers / current_dist_between_fingers 
		var position_between_fingers : Vector2 = get_position_between_fingers(finger_positions_2d[0],finger_positions_2d[1])
		
		two_finger_zoom.emit(_zoom_factor,start_zoom,position_between_fingers)
		var after_zoom_position_3d : Vector3 = view_position_to_3d(position_between_fingers,1)
		finger_indexes_in_work_2d[event.index] = event.position
		finger_positions_2d = finger_indexes_in_work_2d.values()
		position_between_fingers = get_position_between_fingers(finger_positions_2d[0],finger_positions_2d[1])
		var current_zoom_position_3d : Vector3 = view_position_to_3d(position_between_fingers,1)
		var relative_pan : Vector3 = current_zoom_position_3d - after_zoom_position_3d
		two_finger_pan.emit(relative_pan)
	
	
	finger_indexes_in_work_3d[event.index] = view_position_to_3d(event.position,1)


func get_position_between_fingers(pos1:Vector2,pos2:Vector2) -> Vector2: 
	return (pos1+pos2)/2.0


#default detect all masks
func view_position_to_3d(view_pos : Vector2, definite_mask : int = -1 ) -> Vector3:
	var space_state: PhysicsDirectSpaceState3D = main_3d_camera.get_world_3d().direct_space_state
	var ray_from : Vector3 = main_3d_camera.project_ray_origin(view_pos)
	var ray_to : Vector3 = ray_from + main_3d_camera.project_ray_normal(view_pos) * RAY_LENTH
	var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_from,ray_to)
	if definite_mask >= 0:
		query.collision_mask = definite_mask
	var information_about_ray_collision : Dictionary = space_state.intersect_ray(query)
	if information_about_ray_collision.has("position"):
		return information_about_ray_collision["position"]
	push_error("for_finger_pan_zoom coolide mask don't cover all inputs from player")
	return Vector3()

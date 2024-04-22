extends Marker3D

@onready var input_handler : Control = %Input_handler
@onready var main_3d_camera : Camera3D = %Main_3d_camera

@onready var left_limit_marker : Marker3D = %left_limit_marker
@onready var right_limit_marker : Marker3D = %right_limit_marker

@onready var start_z_pos : float = main_3d_camera.position.z

var start_dist_from_camera : float

var deviation : float

var top_limit : float = 8.0
var bot_limit : float = 4.0

var last_z_pos : float

var camera_back_tween : Tween 

const TWEEN_FROM_RIGHT_LEFT : float = 2.0

const SCENE_CAMERA_ORIENTATION : Vector3 = Vector3(0.0,1.0,1.0)

const ZOOM_MAX_ABSOLUTE : float = 5.0
const ZOOM_MAX_TWEEN : float = 3.0
const ZOOM_MIN_ABSOLUTE : float = 0.8
const ZOOM_MIN_TWEEN : float = 1.0
const TWEEN_TRANSITION_SPEED : float = 0.4
const POSITION_BOT_LIMIT_ABSOLUTE : float = 1.0
const POSITION_TOP_LIMIT_ABSOLUTE : float = 10.0
const POSITION_BOT_LIMIT_TWEEN : float = 2.0
const POSITION_TOP_LIMIT_TWEEN : float = 8.0


@export_range(0.0,1000.0) var zoom : float = 1.0:
	set(value):
		if value != 0:
			zoom = value
			main_3d_camera.position.z = start_z_pos - (start_dist_from_camera -(start_dist_from_camera/zoom))
@export var camera_start_position : Vector3 = Vector3(6.0,6.0,0.0)
@export var camera_start_rotation : Vector3 = Vector3(-30.0,90.0,0.0)


func _ready() -> void:
	connect_signals()
	set_camera_to_start_position()
	call_deferred("get_start_dist_from_camera")


func connect_signals() -> void:
	input_handler.one_finger_pan.connect(_make_one_finger_pan)
	input_handler.two_finger_zoom.connect(_make_two_finger_zoom)
	input_handler.two_finger_pan.connect(_make_two_finger_pan)
	input_handler.finger_event_changed.connect(_on_finger_event_changed)
	input_handler.zoom_with_wheel.connect(_on_zoom_with_wheel)
	get_viewport().size_changed.connect(_on_viewport_size_changed)


func get_start_dist_from_camera() -> void:
	var space_state : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var ray_origin : Vector3 = global_position
	var ray_end : Vector3 = ray_origin + Vector3(-1.0,0.0,0.0) *1000
	var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin,ray_end)
	var result_of_collision : Dictionary = space_state.intersect_ray(query)
	start_dist_from_camera = ray_origin.distance_to(result_of_collision.position)


func _make_two_finger_pan(relative_pan : Vector3) -> void:
	position -= relative_pan * SCENE_CAMERA_ORIENTATION
	snap_in_camera_limits()


func _on_viewport_size_changed() -> void:
	snap_in_camera_limits()


func _make_two_finger_zoom(zoom_factor : float,start_zoom : float,zoom_position : Vector2) -> void:
	var previous_zoom_position : Vector3 = input_handler.view_position_to_3d(zoom_position)

	zoom = start_zoom/zoom_factor
	limit_zoom()
	var diff : Vector3 = previous_zoom_position - input_handler.view_position_to_3d(zoom_position)
	position += diff * SCENE_CAMERA_ORIENTATION
	snap_in_camera_limits()


func _on_zoom_with_wheel(zoom_factor : float,start_zoom : float,zoom_position : Vector2) -> void:
	var previous_zoom_position : Vector3 = input_handler.view_position_to_3d(zoom_position)
	zoom = start_zoom/zoom_factor
	limit_zoom(false)
	var diff : Vector3 = previous_zoom_position - input_handler.view_position_to_3d(zoom_position)
	position += diff * SCENE_CAMERA_ORIENTATION
	snap_in_camera_limits(false)


func set_camera_to_start_position() -> void:
	set_position(camera_start_position)
	var deg_rotation : Vector3 = Vector3(deg_to_rad(camera_start_rotation.x),\
	deg_to_rad(camera_start_rotation.y),deg_to_rad(camera_start_rotation.z))
	set_rotation(deg_rotation)
	main_3d_camera.set_position(Vector3.ZERO)
	main_3d_camera.set_rotation(Vector3.ZERO)


func _on_finger_event_changed(started : bool) -> void:
	snap_in_camera_limits()
	if !started:
		var camera_back_tween : Tween = get_tree().create_tween()
	
		camera_back_tween.tween_property(self,"zoom", clampf(zoom,ZOOM_MIN_TWEEN,ZOOM_MAX_TWEEN),
		TWEEN_TRANSITION_SPEED).set_trans(Tween.TRANS_CUBIC)


func _make_one_finger_pan(relative : Vector3) -> void:
	position -= relative * SCENE_CAMERA_ORIENTATION
	snap_in_camera_limits()


func limit_zoom(absolute : bool = true) -> void:
	if absolute:
		zoom = clampf(zoom,ZOOM_MIN_ABSOLUTE,ZOOM_MAX_ABSOLUTE)
		return
	zoom = clampf(zoom,ZOOM_MIN_TWEEN,ZOOM_MAX_TWEEN)
	
var left_clamp : float
func snap_in_camera_limits(absolute : bool = true) -> void:
	#TOP/BOT LIMIT CAMERA
	deviation = main_3d_camera.global_position.y - position.y 
	if absolute:
		position.y = clampf(position.y,POSITION_BOT_LIMIT_ABSOLUTE-deviation,POSITION_TOP_LIMIT_ABSOLUTE- deviation)
	else:
		position.y = clampf(position.y,POSITION_BOT_LIMIT_TWEEN-deviation,POSITION_TOP_LIMIT_TWEEN- deviation)
	
	#LEFT RIGHT LIMIT CAMERA
	var is_left_limit_visible : bool = main_3d_camera.is_position_in_frustum(left_limit_marker.global_position)
	var is_right_limit_visible : bool = main_3d_camera.is_position_in_frustum(right_limit_marker.global_position)
	
	var is_out_of_bounds_left : bool = left_limit_marker.global_position.z < main_3d_camera.global_position.z
	var is_out_of_bounds_right : bool = right_limit_marker.global_position.z > main_3d_camera.global_position.z
	
	if !is_left_limit_visible and !is_right_limit_visible and\
	!is_out_of_bounds_left and !is_out_of_bounds_right :
		return
	
	if is_left_limit_visible and is_right_limit_visible:
		set_camera_to_start_position()
		return
	
	var camera_pos : Vector3 = main_3d_camera.global_position
	var point_from_edge : Vector3
	var diff : float
	var limit_pos : Vector3
	if is_left_limit_visible or is_out_of_bounds_left:
		limit_pos = left_limit_marker.global_position
		var marker_to_2d : Vector2 = main_3d_camera.unproject_position(limit_pos)
		var marker_to_camera_lenth : float = limit_pos.distance_to(camera_pos)
		var left_viewpor_edge_from_marker : Vector2 = Vector2(get_viewport().get_visible_rect().position.x,marker_to_2d.y)
		point_from_edge = camera_pos + main_3d_camera.project_ray_normal(left_viewpor_edge_from_marker) * marker_to_camera_lenth
	
	elif is_right_limit_visible or is_out_of_bounds_right:
		limit_pos = right_limit_marker.global_position
		var marker_to_2d : Vector2 = main_3d_camera.unproject_position(limit_pos)
		var marker_to_camera_lenth : float = limit_pos.distance_to(camera_pos)
		var right_viewpor_edge_from_marker : Vector2 = Vector2(get_viewport().get_visible_rect().end.x,marker_to_2d.y)
		point_from_edge = camera_pos + main_3d_camera.project_ray_normal(right_viewpor_edge_from_marker) * marker_to_camera_lenth
	
	diff = point_from_edge.z - limit_pos.z
	position.z -= diff
	last_z_pos = position.z

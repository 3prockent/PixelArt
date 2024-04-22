extends Node
class_name Caracters

@onready var timer_to_spawn_characters : Timer = %Timer_to_spawn_characters
@onready var timer_to_pop_up_bubble : Timer = %Timer_to_pop_up_bubble
@onready var markers_to_spawn : Node = %Markers_to_spawn
@onready var character_instances : Node = %Character_Instances
@onready var main_3d_camera : Camera3D = %Main_3d_camera
@onready var input_handler : Control = %Input_handler


@onready var characters_dict : Dictionary = {"male_character" : load("res://src/main/3d_scenes/male_character.tscn"),
"female_character" : load("res://src/main/3d_scenes/female_character.tscn")}

var arr_with_spawn_poinst : Array[Node]
var arr_with_emogi : Array 
var arr_with_characters_in_frustum : Array[Node] = []

const EMOGI_PATH : String = "res://src/main/resources/assets/emoji/face_usable/"

@export var spawn_onready : bool = true
@export var spawn_characters : bool = true


func _ready() -> void:
	_connect_signals()
	create_array_with_spawn_poinst()
	create_array_with_emogi()
	spawn_characters_on_ready()
	call_deferred("pop_up_bubble_in_frustum")


func create_array_with_emogi() -> void:
	var files_in_emogi_folder : PackedStringArray = DirAccess.get_files_at(EMOGI_PATH)
	#arr_with_emogi = Array()
	for file in files_in_emogi_folder:
		if(file.get_extension() == "import"):
			arr_with_emogi.append(file.replace(".import",""))


func spawn_characters_on_ready() -> void:
	if !spawn_onready:
		return
	
	
	var number_of_characters : int
	
	var charcter_speed : float = Base_Character.speed
	var interval_beetwen_spawn_character : float = timer_to_spawn_characters.wait_time
	var side_position : float = abs(arr_with_spawn_poinst[0].position.z)
	var distance_between_two_sides : float = side_position * 2.0
	
	number_of_characters = round(charcter_speed * distance_between_two_sides / interval_beetwen_spawn_character)
	
	var characters_on_each_spawnpoint_line : Array[int]
	
	var number_of_spawnpoints : int = arr_with_spawn_poinst.size()
	
	for spawnpoint in range(number_of_spawnpoints):
		characters_on_each_spawnpoint_line.append(0)
	
	for character in range(number_of_characters):
		var random_line : int = randi_range(0,number_of_spawnpoints-1)
		characters_on_each_spawnpoint_line[random_line] += 1
	
	for spawnpoint in range(number_of_spawnpoints):
		var start_point : Vector3 = arr_with_spawn_poinst[spawnpoint].global_position
		var end_point : Vector3 = abs(start_point)
		var positions_on_each_line : Array = get_evenly_spaced_points(start_point,end_point,characters_on_each_spawnpoint_line[spawnpoint])
		for char_pos in positions_on_each_line:
			spawn_random(char_pos)


func get_evenly_spaced_points(start_point : Vector3, end_point : Vector3, num_points: int) -> Array:
	var points : Array
	var total_distance : float = start_point.distance_to(end_point)
	var segment_length : float = total_distance / float(num_points + 1)
	var current_point : Vector3 = start_point
	for i in range(num_points):
		current_point = current_point + (end_point - start_point).normalized() * segment_length
		points.append(current_point)
	return points


func create_array_with_spawn_poinst() -> void:
	arr_with_spawn_poinst = markers_to_spawn.get_children()


func _connect_signals() -> void:
	timer_to_spawn_characters.timeout.connect(_on_timer_timeout)
	timer_to_pop_up_bubble.timeout.connect(_on_timer_to_pop_up_bubble_timeout)
	input_handler.one_finger_tap.connect(_on_one_finger_tap)


func _on_one_finger_tap(collider : Node3D) -> void:
	if collider is Base_Character:
		var speech_bubble_inst : SpeechCharacterBubble = Constants.SCENES.CHARACTER_SPEECH_BUBBLE.instantiate() as SpeechCharacterBubble
		collider.add_child(speech_bubble_inst)


func _on_timer_to_pop_up_bubble_timeout() -> void:
	pop_up_bubble_in_frustum()


func pop_up_bubble_in_frustum() -> void:
	arr_with_characters_in_frustum.clear()
	for character in character_instances.get_children():
		if main_3d_camera.is_position_in_frustum(character.global_position):
			arr_with_characters_in_frustum.append(character)
	try_pop_up_random_bubble_in_frustum()


func try_pop_up_random_bubble_in_frustum() -> void:
	if arr_with_characters_in_frustum.size() > 0:
		var random_character = arr_with_characters_in_frustum.pick_random()
		if random_character not in General.characters_with_bubble:
			var speech_bubble_inst : SpeechCharacterBubble = Constants.SCENES.CHARACTER_SPEECH_BUBBLE.instantiate() as SpeechCharacterBubble
			random_character.add_child(speech_bubble_inst)
		else:
			arr_with_characters_in_frustum.erase(random_character)
			try_pop_up_random_bubble_in_frustum()


func _on_timer_timeout() -> void:
	if spawn_characters:
		spawn_random()


func get_random_character() -> PackedScene:
	var characters_arr : Array = characters_dict.values()
	return characters_arr.pick_random()


func spawn_random(exext_position : Vector3 = Vector3.INF) -> void:
	var spawn_point : Vector3 = arr_with_spawn_poinst.pick_random().global_position
	var random_character : PackedScene = get_random_character()
	
	var character_instance = random_character.instantiate()
	
	# 0-left, 1-right
	var random_side : int = randi_range(0,1)
	
	
	if random_side == 0:
		character_instance.diraction = 1
		if exext_position == Vector3.INF:
			spawn_point = Vector3(spawn_point.x,spawn_point.y,abs(spawn_point.z))
	
	if exext_position != Vector3.INF:
		spawn_point = exext_position
	
	character_instance.start_position = spawn_point
	
	character_instances.add_child(character_instance)
	print(character_instances.get_child_count()," - characters in scene")

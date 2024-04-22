extends Control

class_name ColorPick

@onready var label_number_of_color: Label = %Number_Of_Color
@onready var color_picker_texture_button: TextureButton = %Texture_Button

const DISAPPEARANCE_OFFSET : Vector2 = Vector2(0.0,-300.0)
const DISAPPEARANCE_DURATION : float = 1.0
const UNSELECTED_COLOR : Vector3 = Vector3(1.0,1.0,1.0)
const SELECTED_COLOR : Vector3 = Vector3(0.6,0.6,0.6)

const AMLITUDE_TWEEN_DURATION : float = 5.0
const SELECTED_AMPLITUDE : float = 1.0
const UNSELECTED_AMPLITUDE : float = 0.2
var tween_amplitude : Tween

@export var is_circle_selected:bool = false:
	set(value):
		is_circle_selected = value
		call_deferred("select_circle",value)


@export var circle_color : Color:
	set(value):
		circle_color = value
		call_deferred("set_color_to_circle",value)


@export_range(0,999) var color_number: int:
	set(value):
		color_number = value
		call_deferred("set_color_number",value)


@export_range(0.0,1.0) var color_progress : float = 1.0:
	set(value):
		color_progress = value
		call_deferred("set_color_progress",value)


@export_range(0.0,1.0) var amplitude : float = 0.0:
	set(value):
		amplitude = value
		call_deferred("set_amplitude",value)


func set_amplitude(value : float) -> void:
	color_picker_texture_button.material.set_shader_parameter("amplitude",value)


func select_circle(state:bool) -> void:
	tween_amplitude = get_tree().create_tween()
	if(state):
		color_picker_texture_button.material.set_shader_parameter("outline_color",SELECTED_COLOR)
		tween_amplitude.tween_property(self,"amplitude",SELECTED_AMPLITUDE,AMLITUDE_TWEEN_DURATION)
	else:
		color_picker_texture_button.material.set_shader_parameter("outline_color",UNSELECTED_COLOR)
		tween_amplitude.tween_property(self,"amplitude",UNSELECTED_AMPLITUDE,AMLITUDE_TWEEN_DURATION)


func set_color_progress(value : float) -> void:
	color_picker_texture_button.material.set_shader_parameter("progress",value)


func set_color_number(number:int) -> void:
	label_number_of_color.number = number


func set_color_to_circle(color:Color) -> void:
	color_picker_texture_button.material.set_shader_parameter("base_color",Vector3(color.r,color.g,color.b))


func disable_color_pick() -> void:
	color_picker_texture_button.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)


func animate_disappearance_and_free() -> void:
	disable_color_pick()
	var disappearance_tween : Tween = get_tree().create_tween()
	disappearance_tween.tween_property(color_picker_texture_button,"position",color_picker_texture_button.position - DISAPPEARANCE_OFFSET,DISAPPEARANCE_DURATION).set_trans(Tween.TRANS_BACK)
	disappearance_tween.tween_callback(queue_free)

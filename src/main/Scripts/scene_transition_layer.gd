extends CanvasLayer
class_name SceneTransition

signal transition_on_peak
signal end_trans

@onready var transition_color: ColorRect = %transition_color

var transition_tween : Tween

const TRANSITION_SPEED : float = 1.0


func _ready() -> void:
	General.current_scene_trans = self


func _exit_tree() -> void:
	General.current_scene_trans = null


func start_transition() -> void:
	transition_tween = get_tree().create_tween()
	transition_tween.tween_method(set_shader_transition_progress_param,0.0,1.0,TRANSITION_SPEED).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	transition_tween.tween_callback(func() -> void:
		transition_on_peak.emit())


func end_transition() -> void:
	transition_tween = get_tree().create_tween()
	transition_tween.tween_method(set_shader_transition_progress_param,1.0,0.0,TRANSITION_SPEED).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	transition_tween.tween_callback(func()-> void:
		queue_free()
		end_trans.emit())


func set_shader_transition_progress_param(value : float) -> void:
	transition_color.material.set_shader_parameter("transition_progress",value)

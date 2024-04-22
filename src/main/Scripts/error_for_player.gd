extends Control

class_name Error_for_player

@onready var label : Label = %Label


func push_player_error(text : String,time : float = 3.0, speed : float = 50.0) -> void:
	label.text = text
	var tween : Tween = get_tree().create_tween()
	var finish_pos : Vector2 = %Label.position + Vector2(0.0,time*speed)
	destroy_previous_error()
	tween.tween_property(label, "modulate", Color.TRANSPARENT, time).set_delay(time/2.0)
	tween.parallel().tween_property(label, "position", finish_pos, time).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		self.queue_free
		General.last_player_error = null)


func destroy_previous_error() -> void:
	var previous_player_error : Error_for_player = General.last_player_error
	if previous_player_error != null:
		previous_player_error.queue_free()
	General.last_player_error = get_node(get_path())

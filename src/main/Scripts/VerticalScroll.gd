extends ScrollContainer

@onready var is_allow_to_scroll : bool = true

var stoped_value_of_scroll : int


#func _process(delta):
	#if not is_allow_to_scroll:
		#scroll_vertical = stoped_value_of_scroll


func _on_started_horizontal_scrolls() -> void:
	stoped_value_of_scroll = scroll_vertical
	is_allow_to_scroll = false


func _on_ended_horizontal_scrolls() -> void:
	is_allow_to_scroll = true

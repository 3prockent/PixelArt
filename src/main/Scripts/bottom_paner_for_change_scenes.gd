extends Node

signal button_changed

@onready var horizontal_for_buttons: HBoxContainer = %Horizontal_for_buttons

var all_buttons : Array[TextureButton] = []
var current_button : int = 0

#var path_to_userdata : String = get_user_data_dir() #constant_paths.PROGRESS_PIXELARTS


func _ready() -> void:
	_update_all_buttons()
	_connect_all_buttons()
	_set_current_button()


func _update_all_buttons() -> void:
	for child : int in horizontal_for_buttons.get_child_count():
		if horizontal_for_buttons.get_child(child) is TextureButton:
			all_buttons.append(horizontal_for_buttons.get_child(child))
		else :
			push_error("in horizontal container for buttons must be only buttons!")


func _connect_all_buttons() -> void:
	for button : TextureButton in all_buttons:
		button.toggled.connect(_on_master_toggled)


func _set_current_button() -> void:
	for button : int in all_buttons.size():
		if button != current_button:
			all_buttons[button].set_pressed_no_signal(false)
		else:
			all_buttons[button].set_pressed_no_signal(true)


func _on_master_toggled(toggled_on : bool) -> void:
	if not toggled_on:
		_set_current_button()
	else:
		update_new_current_button()


func update_new_current_button() ->void:
	for button : int in all_buttons.size():
		if all_buttons[button].is_pressed() and button != current_button:
			current_button = button
			_set_current_button()
			button_changed.emit()
			break

func _on_button_reset_pressed():
	for file in DirAccess.get_files_at(Constants.FOLDERS.PROGRESS_PIXELARTS):
		DirAccess.remove_absolute(Constants.FOLDERS.PROGRESS_PIXELARTS+file)
	restart_application()
	
func restart_application():
	get_tree().quit()  # Quit the current instance of the application

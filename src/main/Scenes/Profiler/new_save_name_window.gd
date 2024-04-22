extends Control

class_name NewSaveNameWindow

@onready var new_save_name_window = $"."
@onready var new_name_text_edit : LineEdit =  %TextEdit
@onready var save_button = %SaveButton
@onready var cancel_button = %CancelButton
@onready var new_save_name_window_container = $NewSaveNameWindowContainer

signal new_save_name_entered(enterd_name : String)

const START_MENU_POS : Vector2 = Vector2(0.0,1200.0)

var new_name_text : String:
	get:
		return new_name_text_edit.text
	set(value):
		new_name_text_edit.text = value
		new_name_text = value
		
var previous_text : String


func _ready():
	connect_signals()
	call_deferred("set_previous_text")
	scene_reveal_animations()
	


func set_previous_text() -> void:
	previous_text = new_name_text_edit.text

func connect_signals() -> void:
	save_button.pressed.connect(_on_save_button_pressed)
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	new_name_text_edit.text_changed.connect(_on_text_changed)
	gui_input.connect(SceneManager.out_of_menu_click.bind(get_path()))


func _on_text_changed(new_text: String) -> void:
	var new_text_size : int = new_text.length()
	var curet_position : int = new_name_text_edit.caret_column
	if !new_text_size == 16:
		previous_text = new_text
		return
	new_name_text_edit.text = previous_text
	new_name_text_edit.caret_column = curet_position
	var error : Error_for_player = Constants.SCENES.PLAYER_ERROR.instantiate() as Error_for_player
	get_tree().get_root().add_child(error)
	error.push_player_error("The name must be less than 15 characters!")


func _on_cancel_button_pressed():
	free_scene()
	

func _on_save_button_pressed():
	if(is_save_name_valid(new_name_text)):
		_back_to_choose_menu()


func is_save_name_valid(new_name)->bool:
	if(new_name.is_empty()):
		var error : Error_for_player = Constants.SCENES.PLAYER_ERROR.instantiate() as Error_for_player
		get_tree().get_root().add_child(error)
		error.push_player_error("The field is empty!")
		return false
	if(new_name.length()>15):
		push_error("more than 15 character error")
		return false
	return true


func _input(event):
	if event is InputEventScreenTouch and DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		if DisplayServer.virtual_keyboard_get_height() > 0:
			DisplayServer.virtual_keyboard_hide()


func _back_to_choose_menu():
	new_save_name_entered.emit(new_name_text)
	free_scene()
	
func scene_reveal_animations() -> void:
	SceneManager.animate_scene_reveal(new_save_name_window_container,START_MENU_POS)
	SceneManager.animate_bg_alpha(self)


func free_scene():
	SceneManager.animate_and_free_scene(new_save_name_window_container,START_MENU_POS)
	SceneManager.animate_and_free_bg_alpha(self)





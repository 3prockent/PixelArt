extends Control

class_name EditProfileMenu

@onready var edit_profile_menu = $"."
@onready var name_change_text_edit : LineEdit =  %TextEdit
@onready var back_button = %BackButton
@onready var save_button = %SaveButton
@onready var delete_button = %DeleteButton
@onready var edit_menu_container = %EditMenuContainer

const START_MENU_POS : Vector2 = Vector2(0.0,1200.0)

var save : SavedGame = null
var previous_text : String

#signal profile_display_name_changed(new_display_name : String)
signal edit_profile_menu_closed


var name_change_text : String:
	get:
		return name_change_text_edit.text
	set(value):
		name_change_text_edit.text = value
		name_change_text = value
		
		
		
func _ready() -> void:
	connect_signals()
	call_deferred("set_previous_text")
	scene_reveal_animations()


func set_previous_text() -> void:
	previous_text = name_change_text_edit.text


func connect_signals() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	delete_button.pressed.connect(_on_delete_button_pressed)
	name_change_text_edit.text_changed.connect(_on_text_changed)
	gui_input.connect(SceneManager.out_of_menu_click.bind(get_path()))


func _on_text_changed(new_text: String) -> void:
	var new_text_size : int = new_text.length()
	var curet_position : int = name_change_text_edit.caret_column
	if !new_text_size == 16:
		previous_text = new_text
		return
	name_change_text_edit.text = previous_text
	name_change_text_edit.caret_column = curet_position
	var error : Error_for_player = Constants.SCENES.PLAYER_ERROR.instantiate() as Error_for_player
	get_tree().get_root().add_child(error)
	error.push_player_error("The name must be less than 15 characters!")


func _input(event):
	if event is InputEventScreenTouch and DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		if DisplayServer.virtual_keyboard_get_height() > 0:
			DisplayServer.virtual_keyboard_hide()


func _on_delete_button_pressed():
	var confirm_window_intance = Constants.SCENES.CONFIRMATION_WINDOW.instantiate()
	get_tree().root.add_child(confirm_window_intance)
	confirm_window_intance.delete_confirmed.connect(_on_delete_confirmed)
	
	
func _on_delete_confirmed():
	SaveManager.delete_save(save.get_id())
	var cloud_id = SyncManager.cloud_saves_ids[str(save.get_id())]
	SnapshotsClient.delete_snapshot(cloud_id)
	_back_to_choose_menu()


func _on_save_button_pressed():
	if(is_save_name_valid(name_change_text)):
		save.change_display_name(name_change_text)
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

func _on_back_button_pressed():
	_back_to_choose_menu()
	

func _back_to_choose_menu():
	edit_profile_menu_closed.emit()
	SceneManager.animate_and_free_scene(edit_menu_container,START_MENU_POS)
	SceneManager.animate_and_free_bg_alpha(self)
	
	
func scene_reveal_animations() -> void:
	SceneManager.animate_scene_reveal(edit_menu_container,START_MENU_POS)
	SceneManager.animate_bg_alpha(self)


	

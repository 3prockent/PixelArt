extends Control

signal delete_confirmed

@onready var confirmation_window_container = %ConfirmationWindowContainer

const START_WINDOW_POS : Vector2 = Vector2(0.0,1200.0)

func _ready() -> void:
	gui_input.connect(SceneManager.out_of_menu_click.bind(get_path()))
	scene_reveal_animations()

func _on_decline_button_pressed():
	free_scene()


func _on_confirm_button_pressed():
	delete_confirmed.emit()
	free_scene()
	
func scene_reveal_animations() -> void:
	SceneManager.animate_scene_reveal(confirmation_window_container,START_WINDOW_POS)
	SceneManager.animate_bg_alpha(self)

func free_scene():
	SceneManager.animate_and_free_scene(confirmation_window_container,START_WINDOW_POS)
	SceneManager.animate_and_free_bg_alpha(self)

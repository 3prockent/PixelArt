extends Control

@onready var close_button: ScaledButton = %close_button

func _ready() -> void:
	connect_signals()


func connect_signals() -> void:
	close_button.master_scaled_button_pressed.connect(_on_close_button_pressed)


func _on_close_button_pressed() -> void:
	SceneManager.change_scene_to(Constants.SCENES.MAIN_MENU,true)

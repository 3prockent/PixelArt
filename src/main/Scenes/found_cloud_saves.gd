extends Control

signal sync_confirmed


func _ready() -> void:
	gui_input.connect(SceneManager.out_of_menu_click.bind(get_path()))


func _on_decline_button_pressed():
	Configurator.is_sync_already_choosen = true
	queue_free()


func _on_confirm_button_pressed():
	Configurator.is_sync_already_choosen = true
	sync_confirmed.emit()
	queue_free()

extends Node


@onready var action_button = %ActionButton
@onready var show_current_profile_button = %ShowCurrentProfileButton

@onready var user_name : Label = %user_name

var config = Configurator.config

func _ready():
	_hide_nodes()
	_connect_signals()
	if Engine.has_singleton("GodotPlayGameServices"):
		await SyncManager.user_authentificated_checked
		print("checked")
	_sync_saves()
	var current_save_id = Configurator.current_save_id
	_on_current_save_id_changed(current_save_id)

		

func _connect_signals():
	show_current_profile_button.pressed.connect(_on_show_current_profile_button_pressed)
	Configurator.current_save_id_changed.connect(_on_current_save_id_changed)
	SyncManager.cloud_to_local_synchronized.connect(_on_current_save_id_changed)


func _sync_saves():
	if not SyncManager.is_user_authentificated:
		return
	if Configurator.is_sync_already_choosen:
		print("Suchronize from local to remote")
		SyncManager.sync_all_from_local_to_cloud()
	#Check and sync from cloud to local
	SyncManager.load_saves_from_cloud()




func _on_current_save_id_changed(new_id:int):
	if new_id != -1:
		show_current_profile_button.visible = true
		var profile_display_name = SaveManager.ALL_SAVES[new_id].get_display_name()
		user_name.text = profile_display_name 
		_convert_to_play_button()
	else:
		_convert_to_new_game_button()


func _on_show_current_profile_button_pressed():
	var choose_profile_menu_instance = Constants.SCENES.CHOOSE_PROFILE_MENU.instantiate() as ChooseProfileMenu
	get_tree().root.add_child(choose_profile_menu_instance)
	choose_profile_menu_instance.close_button.pressed.connect(
		func():
		choose_profile_menu_instance.queue_free()
	)
	choose_profile_menu_instance.profile_renamed.connect(
		func():
			if Configurator.current_save_id == -1:
				return
			var chosen_save :SavedGame = SaveManager.ALL_SAVES[Configurator.current_save_id]
			user_name.text = chosen_save.get_display_name()

	)



func _hide_nodes():
	show_current_profile_button.visible = false


func _on_new_game_button_pressed():
	SaveManager.create_save()
	get_tree().change_scene_to_packed(Constants.SCENES.LOADING)
	
	
func _on_play_button_pressed():
	var current_id = Configurator.current_save_id
	SaveManager.load_save(current_id)
	get_tree().change_scene_to_packed(Constants.SCENES.LOADING)
	

func _convert_to_new_game_button():
	if action_button.is_connected("pressed",_on_play_button_pressed):
		action_button.disconnect("pressed",_on_play_button_pressed)
	action_button.text = "New game"
	action_button.pressed.connect(_on_new_game_button_pressed)
	show_current_profile_button.visible = false


func _convert_to_play_button():
	if action_button.is_connected("pressed",_on_new_game_button_pressed):
		action_button.disconnect("pressed",_on_new_game_button_pressed)
	action_button.text = "Play"
	if action_button.is_connected("pressed",_on_play_button_pressed):
		return
	action_button.pressed.connect(_on_play_button_pressed)
	

	

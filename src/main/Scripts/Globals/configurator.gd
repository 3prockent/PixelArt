extends Node

var PATH_TO_CONFIG = Constants.FILES.CONFIG
const SAVE_SECTION:String = "SAVE"

signal current_save_id_changed(new_save_id : int)

var config : ConfigFile = ConfigFile.new()

var current_save_id : int:
	get:
		if config.has_section_key(Configurator.SAVE_SECTION,"current_save_id"):
			return config.get_value(Configurator.SAVE_SECTION,"current_save_id")
		return -1
	set (value):
		config.set_value(Configurator.SAVE_SECTION,"current_save_id", value)
		save()
		current_save_id_changed.emit(value)
		
var is_sync_already_choosen : bool:
	get:
		if config.has_section_key(Configurator.SAVE_SECTION,"is_sync_already_choosen"):
			return config.get_value(Configurator.SAVE_SECTION,"is_sync_already_choosen")
		return false
	set (value):
		config.set_value(Configurator.SAVE_SECTION,"is_sync_already_choosen", value)
		save()
		
func remove_current_save_id():
	config.erase_section_key(Configurator.SAVE_SECTION, "current_save_id")

func _init():
	if not FileAccess.file_exists(PATH_TO_CONFIG):
		print("Create new config file")
		_set_default_settings()
		save()
		return
	config.load(PATH_TO_CONFIG)
	

func _set_default_settings():
	#func to set default properties for config
	is_sync_already_choosen = false
	current_save_id = -1
	
func save():
	config.save(PATH_TO_CONFIG)
	



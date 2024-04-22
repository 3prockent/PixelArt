extends Node

var config = Configurator.config
var ALL_SAVES : Dictionary = {}

func _init():
	_get_all_saves()



func _save():
	if(not config.has_section_key(Configurator.SAVE_SECTION,"current_save_id")):
		push_error("Current save id in config is null")
	var current_save_id = config.get_value(Configurator.SAVE_SECTION,"current_save_id")
	#var path_to_saved_game = ResourceUID.get_id_path(current_save_id)
	#var existingSavedGame = ResourceLoader.load(path_to_saved_game) as SavedGame
	var existingSavedGame = _get_save_from_file(current_save_id)
	#TODO save data logic
	existingSavedGame._money = BalanceManager.balance
	existingSavedGame._current_lvl = LvlManager.current_lvl
	
	ResourceSaver.save(existingSavedGame, existingSavedGame._path_to_save_file)
	

func create_save()->SavedGame:
	#creates and saves file
	var newSavedGame : SavedGame = SavedGame.new()
	newSavedGame.init_save()
	var new_game_id = newSavedGame.get_id()
	load_save(new_game_id)
	ALL_SAVES[new_game_id] = newSavedGame
	Configurator.current_save_id = new_game_id
	_save()
	return newSavedGame
	
	
func create_save_with_name(display_name:String)->void:
	var new_save = create_save()
	new_save.change_display_name(display_name)
	

func _set_current_save_id(id:int)->void:
	Configurator.current_save_id = id
	Configurator.save()
	
	

func load_save(id:int):
	var save_data : SavedGame = _get_save_from_file(id)
	#add changeable var
	BalanceManager.balance = save_data._money
	LvlManager.current_lvl = save_data._current_lvl


func delete_save(id:int):
	var save_to_delete = ALL_SAVES[id]
	ALL_SAVES.erase(id)
	DirAccess.remove_absolute(save_to_delete._path_to_save_file)
	if(id != Configurator.current_save_id):
		return
	if(ALL_SAVES.size()>0):
		var random_existing_save :SavedGame = ALL_SAVES[ALL_SAVES.keys()[0]]
		Configurator.current_save_id = random_existing_save.get_id()
		return
	Configurator.current_save_id=-1
	
	
func _get_save_from_file(id:int)->SavedGame:
	var path_to_saved_game = Constants.FOLDERS.SAVES +str(id)+".tres"
	var foundSavedGame = ResourceLoader.load(path_to_saved_game) as SavedGame
	return foundSavedGame


func get_str_from_save(id:int)->String:
	var path_to_saved_game = Constants.FOLDERS.SAVES +str(id)+".tres"
	var file = FileAccess.open(path_to_saved_game, FileAccess.READ)
	var content = file.get_as_text()
	return content
	

func create_save_from_str(id_file_name: int, string_content:String):
	var path_to_saved_game = get_path_to_file(id_file_name)
	var file = FileAccess.open(path_to_saved_game, FileAccess.WRITE)
	file.store_string(string_content)
	file.close()
	var loaded_save : SavedGame = _get_save_from_file(id_file_name)
	ALL_SAVES[id_file_name] = loaded_save


func write_str_in_save_file():
	pass
	
	
func get_path_to_file(id:int):
	return Constants.FOLDERS.SAVES +str(id)+".tres"

	
func _get_all_saves():
	var path_to_saves_folder = Constants.FOLDERS.SAVES
	if not DirAccess.dir_exists_absolute(path_to_saves_folder):
		DirAccess.make_dir_absolute(path_to_saves_folder)
	for saves in DirAccess.get_files_at(path_to_saves_folder):
		var id = int(Path.get_file_name_without_extension(saves))
		ALL_SAVES[id] = _get_save_from_file(id)
	

func delete_all_local_saves():
	for save_name in DirAccess.get_files_at(Constants.FOLDERS.SAVES):
		DirAccess.remove_absolute(Constants.FOLDERS.SAVES+save_name)
	ALL_SAVES.clear()
	


	



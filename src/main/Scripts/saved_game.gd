class_name SavedGame

extends Resource

@export var _rid : int
@export var _display_name : String
@export var _money : int
@export var _path_to_save_file:String
@export var _current_lvl : int

#called first time on new save created
func init_save():
	_rid = ResourceUID.create_id()
	_display_name = str(_rid).substr(0,10)
	_current_lvl = LvlManager.start_lvl
	create_save_file(_rid)


func change_display_name(new_name : String):
	_display_name = new_name
	save_changes()


func get_id() -> int:
	return _rid
	
	
func get_display_name() -> String:
	return _display_name
	

	
func create_save_file(id : int)->void:
	var file_path = Constants.FOLDERS.SAVES + str(id) + ".tres"
	_path_to_save_file = file_path
	ResourceSaver.save(self, file_path)

	
func save_changes():
	ResourceSaver.save(self, _path_to_save_file)


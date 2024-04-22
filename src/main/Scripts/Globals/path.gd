class_name Path

static func get_last_folder_name(file_path : String) -> String:
	var splitted_path = file_path.split("/")
	return splitted_path[splitted_path.size()-2]
	
static func get_file_name_without_extension(file_path:String) -> String:
	return file_path.get_file().get_slice(".",0)

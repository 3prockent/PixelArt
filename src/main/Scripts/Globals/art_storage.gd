extends Node

signal progress_changed(percentage)
signal updated

#The key: art unique code(ex. "cow")
#The value: pixelArt of type PixelArtTexture
var ALL_ARTS : Dictionary = {}
var ALL_THEMES : Dictionary = {}
var all_arts_count : int = 0 
var current_art_texture : PixelArtTexture:
	set(texture):
		current_art_texture = texture


func _init():
	_get_all_files_count()
	print(all_arts_count)
	pass
	
func update_all_arts():
	var pixel_arts_folder : String = Constants.FOLDERS.PIXELARTS
	for folder in DirAccess.get_directories_at(pixel_arts_folder):
		for file in DirAccess.get_files_at(pixel_arts_folder+folder):
			file = file.replace('.import', '')
			if(file.get_extension() == "png"):
				_update_pixel_art(pixel_arts_folder+folder+"/"+file)
				progress_changed.emit(_get_update_progress())
	print("updated")
	updated.emit()




func _update_pixel_art(file_path : StringName):
	var file_name_without_extension = file_path.get_file().get_slice(".",0)
	if not ALL_ARTS.has(file_name_without_extension):
		var new_art = _create_pixel_art(file_path)
		ALL_ARTS[file_name_without_extension] = new_art
	

func _create_pixel_art(image_path : String) -> PixelArtTexture:
	var art = PixelArtTexture.new()
	art.create(image_path)
	_update_theme(art)
	return art

func _update_theme(art : PixelArtTexture) -> void:
	var theme : String = art.theme
	var artName : String = Path.get_file_name_without_extension(art.path_to_source_png)
	if theme.is_empty():
		push_error("pixel art {artName} doesn't have theme".format(
			{"artName":artName}))
	if not ALL_THEMES.has(theme):
		ALL_THEMES[theme] = []
	ALL_THEMES[theme].append(art)
	
func get_themes_count() -> int:
	return ALL_THEMES.size()

func get_themes() -> PackedStringArray:
	var themes : PackedStringArray = ALL_THEMES.keys()
	return themes

func get_arts_in_theme(theme : String) -> Array[PixelArtTexture]:
	var artArray : Array[PixelArtTexture] = []
	for art in ALL_THEMES[theme]:
		artArray.append(art)
	return artArray


func get_arts_count(theme : String) -> int:
	var arts_count : int = get_arts_in_theme(theme).size()
	return arts_count
	
func _get_update_progress() -> float:
	var progress : float = float(ALL_ARTS.size())/all_arts_count*100
	return progress
	
	
func _get_all_files_count() -> void:
	var pixel_arts_folder : String = Constants.FOLDERS.PIXELARTS
	for folder in DirAccess.get_directories_at(pixel_arts_folder):
		for file in DirAccess.get_files_at(pixel_arts_folder+folder):
			if(file.get_extension() == "import"):
				all_arts_count+=1




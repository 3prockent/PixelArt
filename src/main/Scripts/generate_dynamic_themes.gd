extends VBoxContainer

func _ready():
	generate_theme()

func generate_theme() -> void:
	for theme_name : String in ArtStorage.get_themes():
		var theme_section_scene = Constants.SCENES.THEME_SECTION
		var theme_scene_instance = theme_section_scene.instantiate()
		var art_in_theme : Array[PixelArtTexture] = ArtStorage.get_arts_in_theme(theme_name)
		theme_scene_instance.theme_name = theme_name
		add_child(theme_scene_instance)

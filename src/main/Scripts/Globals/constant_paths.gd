extends  Node

#Folder paths
class FOLDERS:
	static var PIXELARTS : String = "res://src/main/resources/assets/pixel_arts/"
	static var PROGRESS_PIXELARTS : String = OS.get_user_data_dir()+"/progress/"
	static var SAVES : String = OS.get_user_data_dir()+"/saves/"
	static var USER : String = OS.get_user_data_dir()

class FILES:
	static var CONFIG : String = OS.get_user_data_dir()+"/config.cfg"


#Scenes
class SCENES:
	static var SINGLE_ART : PackedScene = load("res://src/main/Scenes/single_art.tscn")
	static var THEME_SECTION : PackedScene = load("res://src/main/Scenes/theme_section.tscn")
	static var DRAWING : PackedScene = load("res://src/main/Scenes/drawing.tscn")
	static var MAIN_MENU : PackedScene = load("res://src/main/Scenes/main_menu.tscn")
	static var COLOR_PICKER : PackedScene = load("res://src/main/Scenes/color_picker.tscn")
	static var LOADING : PackedScene = load("res://src/main/Scenes/loading_screen.tscn")
	static var EASEL_PLAY_MENU : PackedScene = load("res://src/main/Scenes/easel_play_menu.tscn")
	#Profiler_Scenes
	static var PROFILE_ITEM : PackedScene = load("res://src/main/Scenes/Profiler/profile_item.tscn")
	static var CHOOSE_PROFILE_MENU : PackedScene = load("res://src/main/Scenes/Profiler/choose_profile_menu.tscn")
	static var EDIT_PROFILE_MENU : PackedScene = load("res://src/main/Scenes/Profiler/edit_profile_menu.tscn")
	static var CONFIRMATION_WINDOW : PackedScene = load("res://src/main/Scenes/Profiler/confirmation_window.tscn")
	static var NEW_SAVE_NAME_WINDOW : PackedScene = load("res://src/main/Scenes/Profiler/new_save_name_window.tscn")
	
	#transition scene
	static var SCENE_TRANSITION_LAYER = load("res://src/main/Scenes/scene_transition_layer.tscn")
	#error_for_player
	static var PLAYER_ERROR : PackedScene = load("res://src/main/Scenes/error_for_player.tscn")
	#speech_bubble
	static var CHARACTER_SPEECH_BUBBLE : PackedScene = load("res://src/main/3d_scenes/character_speech_bubble.tscn")

	static var FOUND_CLOUD_SAVES_CONFIRMATION : PackedScene = load("res://src/main/Scenes/found_cloud_saves.tscn")

	

class SYNC:
	static var LEADERBOARD_ID : String = "CgkI6cO83p0aEAIQCg"

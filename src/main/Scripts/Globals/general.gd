extends Node

#saving last pushed error
var last_player_error : Error_for_player

#saving characters with speech_bubble
var characters_with_bubble : Array

# alpha threshold for images without background
const ALPHA_THRESHOLD : float = 0.5

# current scene trans 
var current_scene_trans : SceneTransition:
	set(value):
		if current_scene_trans and value:
			push_error("Two trans in scene error, all two was freed, check logic!")
			current_scene_trans.queue_free()
			value.queue_free()
			current_scene_trans = null
		else:
			current_scene_trans = value

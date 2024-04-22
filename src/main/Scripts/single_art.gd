extends Control

@onready var texture_of_art : TextureButton = $Size_of_frame/Texture_of_art

var texture : PixelArtTexture = PixelArtTexture.new() 

func _ready() -> void:
	connect_signals()
	set_texture_art(texture)


func set_texture_art(texture : PixelArtTexture) -> void :
	texture_of_art.set_texture_normal(texture)


func connect_signals() -> void:
	texture_of_art.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	ArtStorage.current_art_texture = texture
	SceneManager.change_scene_to(Constants.SCENES.DRAWING)

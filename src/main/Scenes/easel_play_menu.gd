extends ColorRect

class_name EaselPlayMenu

signal close_button_pressed

@onready var art: TextureRect = %art
@onready var play_button: Button = %Play_button
@onready var lvl_number: Label = %lvl_number
@onready var close_button: ScaledButton = %close_button

@onready var bot_alignment_container: AspectRatioContainer = %bot_alignment_container
@onready var indent_for_ui_hud: Control = %Indent_for_ui_hud

@onready var current_lvl_art : PixelArtTexture = ArtStorage.get_arts_in_theme("LVL")[LvlManager.current_lvl-1]

var scene_animation_tween : Tween

const START_HUD_POS : Vector2 = Vector2(0.0,-400.0)
const START_EASEL_POS : Vector2 = Vector2(0.0,1200.0)


func _ready() -> void:
	connect_signals()
	set_texture_to_easel()
	set_lvl_star()
	scene_reveal_animations()


func set_lvl_star() -> void:
	lvl_number.set_current_lvl()


func set_texture_to_easel() -> void:
	art.set_texture(current_lvl_art)


func connect_signals() -> void:
	close_button.master_scaled_button_pressed.connect(on_closed_button_pressed)
	play_button.pressed.connect(_on_play_button_pressed)


func _on_play_button_pressed() -> void:
	ArtStorage.current_art_texture = current_lvl_art
	SceneManager.change_scene_to(Constants.SCENES.DRAWING,true)


func on_closed_button_pressed() -> void:
	close_button_pressed.emit()
	SceneManager.animate_and_free_scene(indent_for_ui_hud,START_HUD_POS)
	SceneManager.animate_and_free_scene(bot_alignment_container,START_EASEL_POS)
	SceneManager.animate_and_free_bg_alpha(self)


func scene_reveal_animations() -> void:
	SceneManager.animate_scene_reveal(bot_alignment_container,START_EASEL_POS)
	SceneManager.animate_scene_reveal(indent_for_ui_hud,START_HUD_POS)
	SceneManager.animate_bg_alpha(self)

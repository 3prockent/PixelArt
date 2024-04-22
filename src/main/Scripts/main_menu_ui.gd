extends Control

@onready var Play_button: Control = %Play_button
@onready var input_handler: Input_handler_3d = %Input_handler

const MOVE_PLAYBUTTON_OFFSET : Vector2 = Vector2(500,0)

var play_button_move_tween : Tween


func _ready() -> void:
	connect_signals()


func connect_signals() -> void:
	Play_button.scaled_button.master_scaled_button_pressed.connect(on_play_button_pressed)

func on_play_button_pressed() -> void:
	var easel_play_menu_instance : EaselPlayMenu = Constants.SCENES.EASEL_PLAY_MENU.instantiate() as EaselPlayMenu
	input_handler.add_child(easel_play_menu_instance)
	input_handler.move_child(easel_play_menu_instance,0)
	easel_play_menu_instance.close_button_pressed.connect(func() -> void:move_play_button(false))
	move_play_button(true)


func kill_if_active() -> void:
	if play_button_move_tween and play_button_move_tween.is_valid() and play_button_move_tween.is_running():
		play_button_move_tween.kill()


func move_play_button(out : bool = false) -> void:
	kill_if_active()
	play_button_move_tween = get_tree().create_tween()
	var final_pos_value : Vector2
	if out:
		Play_button.scaled_button.disable_button()
		final_pos_value = Play_button.position + MOVE_PLAYBUTTON_OFFSET
	else:
		Play_button.scaled_button.unable_button()
		final_pos_value = Play_button.position - MOVE_PLAYBUTTON_OFFSET
	play_button_move_tween.tween_property(Play_button,"position",final_pos_value,SceneManager.ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC)



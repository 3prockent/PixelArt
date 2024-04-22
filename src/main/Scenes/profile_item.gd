extends MarginContainer

class_name ProfileItem

@onready var profile_display_name_label : Label = %ProfileDisplayNameLabel
@onready var edit_button : TextureButton = %EditButton
@onready var profile_item: MarginContainer = $"."
@onready var tougle_choose_player_button : Button = %Tougle_choose_player_button

var save : SavedGame


func _ready() -> void:
	tougle_choose_player_button.toggled.connect(get_parent().owner.master_tougle_buttons.bind(tougle_choose_player_button.get_path()))



var item_display_name : String:
	set(value):
		profile_display_name_label.text = value
		item_display_name = value


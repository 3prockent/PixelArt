extends VBoxContainer

@onready var horizontal_scroll_in_group : ScrollContainer = $HorizontalScroll_in_group
@onready var vertical_scroll : ScrollContainer = $"../../.."
@onready var container_1 : HBoxContainer = $"HorizontalScroll_in_group/Horizontal_colons_in_group/1_Container_for_vertically_arranging_arts_in_group"
@onready var container_2 : HBoxContainer = $"HorizontalScroll_in_group/Horizontal_colons_in_group/2_Container_for_vertically_arranging_arts_in_group"
@onready var is_allow_to_scroll : bool = true
@onready var section_name_label : Label = $Name_Of_GroupOfArts

@export var theme_name :String = ""


var stoped_value_of_scroll : int

#TODO
func _ready():
	_connect_signals()
	set_group_label(theme_name)
	set_group_arts(ArtStorage.get_arts_in_theme(theme_name))


#func _process(delta):
	#if not is_allow_to_scroll:
		#horizontal_scroll_in_group.scroll_vertical = stoped_value_of_scroll

func set_group_label(text : String) -> void:
	section_name_label.set_text(text)

func set_group_arts(arts : Array[PixelArtTexture]) -> void:
	for i in range(arts.size()):
		var single_art_scene = Constants.SCENES.SINGLE_ART
		var art : PixelArtTexture = arts[i]
		var single_art_scene_instance = single_art_scene.instantiate()
		single_art_scene_instance.texture = art
		if i%2==0:
			container_1.add_child(single_art_scene_instance)
		else:
			container_2.add_child(single_art_scene_instance)


func _connect_signals() -> void:
	#Connect end and start scroll signals from this horizontal scroll to vetical
	horizontal_scroll_in_group.scroll_started.connect(vertical_scroll._on_started_horizontal_scrolls)
	horizontal_scroll_in_group.scroll_ended.connect(vertical_scroll._on_ended_horizontal_scrolls)
	
	#Connect end and start scroll signals to this horizontal from vetical scroll
	vertical_scroll.scroll_started.connect(_on_started_vertical_scrolls)
	vertical_scroll.scroll_ended.connect(_on_ended_vertical_scrolls)


func _on_started_vertical_scrolls() -> void:
	stoped_value_of_scroll = horizontal_scroll_in_group.scroll_vertical
	is_allow_to_scroll = false


func _on_ended_vertical_scrolls() -> void:
	is_allow_to_scroll = true

extends Control

class_name ChooseProfileMenu


@onready var profile_item_container = %ProfileItemContainer
@onready var choose_button = %ChooseButton
@onready var close_button : TextureButton = %CloseButton
@onready var add_profile_item = %AddProfileItem
@onready var add_button = %AddButton
@onready var choose_menu_container = %ChooseMenuContainer

const PROFILE_ITEMS_IN_SCROLL : float = 4.0
const START_CHOOSE_MENU_POS : Vector2 = Vector2(0.0,1200.0)

var profile_items : Array[ProfileItem] =[]
var chosen_item :ProfileItem = null

var previous_tougl_button : Button

signal profile_renamed
signal profile_changed

func _ready():
	update_item_list()
	_connect_signals()
	scene_reveal_animations()


func _connect_signals():
	choose_button.pressed.connect(_on_choose_button_pressed)
	add_button.pressed.connect(_on_add_button_pressed)
	gui_input.connect(SceneManager.out_of_menu_click.bind(get_path()))


func _on_add_button_pressed():
	var get_new_name_window_instance = Constants.SCENES.NEW_SAVE_NAME_WINDOW.instantiate()
	get_tree().root.add_child(get_new_name_window_instance)
	get_new_name_window_instance.new_save_name_entered.connect(_on_new_save_name_entered)
	
	
func _on_new_save_name_entered(new_name:String):
	SaveManager.create_save_with_name(new_name)
	visible = false
	profile_renamed.emit()


func update_item_list():
	choose_button.disabled = true
	for item in profile_item_container.get_children():
		if(item == add_profile_item):
			continue
		profile_item_container.remove_child(item)
		item.queue_free()
	for save in SaveManager.ALL_SAVES.values():
		var profile_item_instance = Constants.SCENES.PROFILE_ITEM.instantiate() as ProfileItem
		var index_to_move = profile_item_container.get_child_count()-1
		profile_item_container.add_child(profile_item_instance)
		profile_item_container.move_child(profile_item_instance,index_to_move)
		profile_item_instance.item_display_name = save._display_name
		profile_item_instance.save = save
		
		profile_item_instance.edit_button.pressed.connect(_on_edit_button_pressed.bind(profile_item_instance))
		
		profile_items.append(profile_item_instance)
		
		

func _on_edit_button_pressed(profile_item : ProfileItem):
	#visible = false
	var edit_profile_menu_instantiate = Constants.SCENES.EDIT_PROFILE_MENU.instantiate()
	get_tree().root.add_child(edit_profile_menu_instantiate)
	edit_profile_menu_instantiate.name_change_text = profile_item.item_display_name
	edit_profile_menu_instantiate.save = profile_item.save
	edit_profile_menu_instantiate.edit_profile_menu_closed.connect(_on_edit_menu_closed)


func _on_edit_menu_closed():
	update_item_list()
	#visible = true
	profile_renamed.emit()


func master_tougle_buttons(state : bool,profile_item_path : String) -> void:
	var current_button : Button = get_node(profile_item_path)
	if state and previous_tougl_button != null:
		previous_tougl_button.set_pressed_no_signal(false)
	else:
		current_button.set_pressed_no_signal(true)
	previous_tougl_button = current_button
	chosen_item = current_button.owner
	choose_button.disabled = false


func _on_choose_button_pressed():
	if chosen_item == null:
		push_error("no chosen item")
		return
	Configurator.current_save_id = chosen_item.save.get_id()
	free_scene()
	

func scene_reveal_animations() -> void:
	SceneManager.animate_scene_reveal(choose_menu_container,START_CHOOSE_MENU_POS)
	SceneManager.animate_bg_alpha(self)
	
func free_scene():
	SceneManager.animate_and_free_scene(choose_menu_container,START_CHOOSE_MENU_POS)
	SceneManager.animate_and_free_bg_alpha(self)
	

@tool
extends Node


var android_smartphones : Dictionary = {"Pixel 7 Pro":Vector2i(1440,3120),
"Pixel 5":Vector2i(1080,2340),"Realme 6 Pro":Vector2i(1080,2400),
"Samsung Galaxy A24":Vector2i(1080,2340),"Samsung Galaxy S23 Ultra":Vector2i(1440,3088),
"Nokia G22":Vector2i(720,1600),"Xiaomi Redmi Note 12":Vector2i(1080,2400)}

var ios_smartphones : Dictionary = {"iPhone 15 Pro Max":Vector2i(1290,2796),
"iPhone 15":Vector2i(1179 ,2556),"iPhone 11":Vector2i(828,1792),
"iPhone 7":Vector2i(750,1334)}

var android_tablets : Dictionary = {"Lenovo Tab P11 Plus":Vector2i(2000,1200),
"Samsung Galaxy Tab S9":Vector2i(2560,1600),"Xiaomi Mi Pad 6":Vector2i(2880,1800)}

var ios_tablets : Dictionary = {"iPad Pro 6th-gen":Vector2i(2048,2732),
"iPad Pro 4th-gen":Vector2i(1668,2388),"iPad 10th-gen":Vector2i(1640,2360),
"iPad mini 6th-gen":Vector2i(1488,2266),"iPad 8th-gen":Vector2i(1620,2160)}


@export_category("Device Picker")

@export_enum("Smartphone","Tablet") var Device : String:
	set(value):
		if Device != value:
			var_reset(2)
		Device = value
		if Device == "":
			hide_vars(3)
		else:
			show_vars(3)
		notify_property_list_changed()


@export_enum("Android","Ios") var System : String:
	set(value):
		if System != value:
			var_reset(1)
		if value == "reset":
			System = ""
		else:
			System = value
		if System == "":
			hide_vars(2)
		else:
			show_vars(2)
		notify_property_list_changed()


@export_enum("_") var Model : String:
	set(value):
		if value == "reset":
			Model = ""
		else:
			Model = value
		if Model == "":
			hide_vars(1)
		else:
			show_vars(1)
		notify_property_list_changed()


@export var Set : bool:
	set(value):
		notify_property_list_changed()
		Set = false
		set_window_size(get_resolution())

@export_range(1.0,8.0) var ratio : float = 4.0:
	set(value):
		ratio = value
		if set_usage == 6:
			set_window_size(get_resolution())

@export_category("Remove progress")

@export var Set_remove_progress : bool:
	set(value):
		Set_remove_progress = value
		create_reset_button(value)

func _ready() -> void:
	create_reset_button(Set_remove_progress)

func create_reset_button(value):
	if value == true:
		var reset_image_path = "res://src/main/resources/assets/menu_pictures/reset_debug.png"
		var new_button = TextureButton.new()
		add_child(new_button)
		change_button_properties(new_button, true, Vector2(200, 200), Vector2(0, 100), 5, 3, 0, reset_image_path)
		new_button.button_down.connect(_on_button_reset_pressed)
	if value == false:
		#TODO: Fix reset button when changing from drawing scene
		for child in get_children():
			child.queue_free()

func change_button_properties(this_Button : TextureButton, ignore_texture_size : bool,\
	custom_minimum_size : Vector2, position : Vector2, stretch_mode : int, layout_direction : int,\
	anchors_preset : int, texture_path : String,):
	this_Button.set_ignore_texture_size(ignore_texture_size)
	this_Button.set_custom_minimum_size(custom_minimum_size)
	this_Button.set_position(position)
	this_Button.set_stretch_mode(stretch_mode)
	this_Button.set_layout_direction(layout_direction)
	this_Button.set_anchors_preset(anchors_preset)
	this_Button.texture_normal = load(texture_path)


#TODO implement deleting whole user folder
func _on_button_reset_pressed():
	for file in DirAccess.get_files_at(Constants.FOLDERS.USER):
		DirAccess.remove_absolute(Constants.FOLDERS.USER + "/" + file)
	for dir in DirAccess.get_directories_at(Constants.FOLDERS.USER):
		for file in DirAccess.get_files_at(Constants.FOLDERS.USER +"/"+ dir):
			DirAccess.remove_absolute(Constants.FOLDERS.USER +"/" + dir + "/" + file)
	restart_application()


func restart_application():
	get_tree().quit()  # Quit the current instance of the application


func get_resolution()->Vector2i:
	var resolution : Vector2i = get_dictionary_from_device_and_system()[Model]/ratio
	return resolution


var system_usage : int
var model_usage : int
var set_usage : int


func show_vars(vars:int) -> void:
	if vars == 1:
		set_usage = PROPERTY_USAGE_DEFAULT
	if vars == 2:
		model_usage = PROPERTY_USAGE_DEFAULT
	if vars == 3:
		system_usage = PROPERTY_USAGE_DEFAULT


func hide_vars(vars:int) -> void:
	set_usage = PROPERTY_USAGE_NO_EDITOR
	if vars == 2:
		model_usage = PROPERTY_USAGE_NO_EDITOR
	if vars == 3:
		system_usage = PROPERTY_USAGE_NO_EDITOR


func var_reset(vars:int) -> void:
	Model = "reset"
	match vars:
		2:
			System = "reset"


func _validate_property(property: Dictionary) -> void:
	if property.name == "System":
		property.usage = system_usage
	if property.name == "Model":
		if model_usage == PROPERTY_USAGE_NO_EDITOR:
			property.hint_string = ""
		else:
			var hint_string : String
			var models_array : PackedStringArray
			
			models_array = get_dictionary_from_device_and_system().keys()
			hint_string = ",".join(models_array)
			
			property.hint_string = hint_string
		property.usage = model_usage
	if property.name == "Set":
		property.usage = set_usage


func get_dictionary_from_device_and_system() -> Dictionary:
	var current_dictionary : Dictionary
	match Device:
		"Smartphone":
			match System:
				"Android":
					current_dictionary = android_smartphones
				"Ios":
					current_dictionary = ios_smartphones
		"Tablet":
			match System:
				"Android":
					current_dictionary = android_tablets
				"Ios":
					current_dictionary = ios_tablets
	return current_dictionary


func set_window_size(size:Vector2i) -> void:
	if not Engine.is_editor_hint():
		if get_window():
			get_window().set_size(size)


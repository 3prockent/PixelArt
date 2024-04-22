extends Label

@export_range(0.0,1.0) var shadow_size : float = 0.0:
	set(value):
		shadow_size = value
		call_deferred("set_font_size_from_char")


@export var font_size_one_char : int
@export var font_size_two_char : int
@export var font_size_three_char : int

@export var use_multiplies_insted : bool = false

@export_range(0.0,1.0) var font_mult_one_char : float
@export_range(0.0,1.0) var font_mult_two_char : float
@export_range(0.0,1.0) var font_mult_three_char : float

var number : int :
	set(value):
		number = value
		text = str(number)
		call_deferred("set_font_size_from_char")


func _ready() -> void:
	resized.connect(func()->void:
		call_deferred("set_font_size_from_char"))


func set_current_lvl() -> void:
	text = str(LvlManager.current_lvl)
	set_font_size_from_char()


func set_font_size_from_char() -> void:
	var lvl_number_size : int
	lvl_number_size = text.length()
	var font_size : int
	if use_multiplies_insted:
		match lvl_number_size:
			1:
				font_size = int(size.x * font_mult_one_char)
			2:
				font_size = int(size.x * font_mult_two_char)
			3:
				font_size = int(size.x * font_mult_three_char)
			_:
				push_error("unhandled lvl number")
				return
	else:
		match lvl_number_size:
			1:
				font_size = font_size_one_char
			2:
				font_size = font_size_two_char
			3:
				font_size = font_size_three_char
			_:
				push_error("unhandled lvl number")
				return
	
	label_settings.set_font_size(font_size)
	label_settings.set_shadow_size(int(font_size*shadow_size))


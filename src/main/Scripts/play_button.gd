extends Control

@onready var number_of_lvl: Label = %number_of_lvl
@onready var scaled_button: ScaledButton = $ScaledButton

func _ready() -> void:
	number_of_lvl.set_current_lvl()

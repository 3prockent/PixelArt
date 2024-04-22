extends Control
class_name ScaledButton

signal master_scaled_button_pressed

var tween_button_down : Tween 
var tween_button_up : Tween 

const ANIMATION_DURATION : float = 0.05

@export var child_button : Control
@export var power_of_scale : float = 0.9

func _ready():
	get_child_button()
	connect_signals()
	call_deferred("set_pivot_to_center")


func connect_signals() -> void:
	resized.connect(_on_resized)
	if child_button is BaseButton:
		child_button.button_down.connect(on_button_down)
		child_button.button_up.connect(on_button_up)
		child_button.pressed.connect(on_button_pressed)
	elif child_button is Control:
		child_button.gui_input.connect(_on_gui_input)
	else:
		push_error("unexpected node type")


func on_button_pressed() -> void:
	master_scaled_button_pressed.emit()


func get_child_button():
	if child_button == null:
		child_button = self


func _on_resized() -> void:
	call_deferred("set_pivot_to_center")


func set_pivot_to_center() -> void:
	pivot_offset = Vector2(size.x/2.0,size.y/2.0)


func _on_gui_input(event : InputEvent):
	if event is InputEventScreenTouch and event.is_pressed():
		on_button_down()
	elif event is InputEventScreenTouch and event.is_released():
		on_button_up()
		if Rect2(Vector2(0.0,0.0),size).has_point(event.position):
			master_scaled_button_pressed.emit()


func on_button_down() -> void:
	kill_if_active()
	tween_button_down = get_tree().create_tween()
	tween_button_down.tween_property(self,"scale",Vector2(power_of_scale,power_of_scale),ANIMATION_DURATION)


func on_button_up() -> void:
	kill_if_active()
	if is_inside_tree():
		tween_button_up = get_tree().create_tween()
		tween_button_up.tween_property(self,"scale",Vector2(1.0,1.0),ANIMATION_DURATION)
	

func disable_button() -> void:
	child_button.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)


func unable_button() -> void:
	child_button.set_mouse_filter(Control.MOUSE_FILTER_STOP)


func kill_if_active() -> void:
	if tween_button_down and tween_button_down.is_valid() and tween_button_down.is_running():
		tween_button_down.kill()
	if tween_button_up and tween_button_up.is_valid() and tween_button_up.is_running():
		tween_button_up.kill()

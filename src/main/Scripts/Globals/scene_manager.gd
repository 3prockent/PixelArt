extends Node

const MINIMAL_TRANS_AWAIT_TIME : float = 0.5

## example of connecting :
## gui_input.connect(SceneManager.out_of_menu_click.bind(get_path()))

func out_of_menu_click(event : InputEvent,absolute_path : String) -> void:
	if event is InputEventScreenTouch and event.is_released():
		var scene_node : Control = get_node(absolute_path)
		if scene_node is ColorRect:
			animate_and_free_scene(scene_node.get_child(0))
			animate_and_free_bg_alpha(scene_node)
		else:
			animate_and_free_scene(scene_node)


func change_scene_to(Scene : PackedScene,is_use_transition : bool = false) -> void:
	if !is_use_transition:
		get_tree().call_deferred("change_scene_to_packed",Scene)
		return
	else:
		var scene_transition_instance : CanvasLayer = Constants.SCENES.SCENE_TRANSITION_LAYER.instantiate() as SceneTransition
		
		get_tree().get_root().add_child(scene_transition_instance)
		
		scene_transition_instance.transition_on_peak.connect(func() -> void:
			var minimal_timer_to_end_trans : SceneTreeTimer = get_tree().create_timer(MINIMAL_TRANS_AWAIT_TIME)
			await get_tree().call_deferred("change_scene_to_packed",Scene)
			if minimal_timer_to_end_trans:
				await minimal_timer_to_end_trans.timeout
			scene_transition_instance.end_transition()
			)
		
		scene_transition_instance.start_transition()
		


const ANIMATION_DURATION : float = 0.5
const START_SCALE_ELEMENTS : Vector2 = Vector2(0.8,0.8)

var scene_animation_tween : Tween


func animate_scene_reveal(scene_node : Control, start_pos_offset : Vector2 = Vector2(0.0,1400)) -> void:
	var center_or_rect : Vector2 = Vector2(scene_node.size.x / 2.0,scene_node.size.y / 2.0)
	scene_node.set_pivot_offset(center_or_rect)
	scene_node.scale = START_SCALE_ELEMENTS
	scene_node.position = start_pos_offset
	scene_node.modulate.a = 0.0
	
	scene_animation_tween = get_tree().create_tween()
	scene_animation_tween.parallel().tween_property(scene_node,"position",Vector2.ZERO,ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC)
	scene_animation_tween.parallel().tween_property(scene_node,"scale",Vector2.ONE,ANIMATION_DURATION).set_trans(Tween.TRANS_CUBIC)
	scene_animation_tween.parallel().tween_property(scene_node,"modulate:a",1.0,ANIMATION_DURATION)


func animate_and_free_scene(scene_node : Control, finish_pos_offset : Vector2 = Vector2(0.0,1400),trans : int = Tween.TRANS_CUBIC,ease : int = Tween.EASE_IN_OUT) -> void:
	scene_animation_tween = get_tree().create_tween()
	
	scene_animation_tween.parallel().tween_property(scene_node,"position",finish_pos_offset,ANIMATION_DURATION).set_trans(trans).set_ease(ease)
	scene_animation_tween.parallel().tween_property(scene_node,"scale",START_SCALE_ELEMENTS,ANIMATION_DURATION).set_trans(trans).set_ease(ease)
	scene_animation_tween.parallel().tween_property(scene_node,"modulate:a",0.0,ANIMATION_DURATION)
	
	scene_animation_tween.tween_callback(free_if_posible.bind(scene_node))


func animate_and_free_bg_alpha(node : Control) -> void:
	scene_animation_tween = get_tree().create_tween()
	scene_animation_tween.tween_property(node,"color:a",0.0,ANIMATION_DURATION)
	scene_animation_tween.tween_callback(free_if_posible.bind(node))


func free_if_posible(node : Control) -> void:
	if node.is_inside_tree(): node.queue_free()


func animate_bg_alpha(node : Control, final_alpha : float = 0.5) -> void:
	node.color.a = 0.0
	scene_animation_tween = get_tree().create_tween()
	scene_animation_tween.tween_property(node,"color:a",final_alpha,ANIMATION_DURATION)

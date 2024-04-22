extends Sprite3D
class_name SpeechCharacterBubble

@onready var booble_texture : Sprite2D = %Booble_texture
@onready var emoji_texture : Sprite2D = %emoji_texture
@onready var character_owner : CharacterBody3D = get_parent() 

const BUBBLE_SCALE : Vector3 = Vector3(0.64,0.64,0.64)

const BUBBLE_OFFSET_TYPE_BUBBLE : Dictionary = {0.65:preload("res://src/main/resources/assets/emoji/left_speech_bubble_3d.png"),
-0.65:preload("res://src/main/resources/assets/emoji/right_anger_bubble_3d.png")}

var local_bubble_pos : Vector3 = Vector3(0.0,2.833,0.0)

func _ready() -> void:
	if is_bubble_valid():
		General.characters_with_bubble.append(character_owner)
		set_random_bubble()
		pop_up_bubble()
		create_timer_and_delete()


func is_bubble_valid() -> bool:
	return character_owner not in General.characters_with_bubble


func _process(delta : float) -> void:
	global_position = character_owner.global_position + local_bubble_pos


func create_timer_and_delete() -> void:
	await get_tree().create_timer(7.0).timeout
	var pop_down_tween : Tween = get_tree().create_tween()
	pop_down_tween.tween_property(self,"scale",Vector3(0.0,0.0,0.0),1.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	pop_down_tween.tween_callback(func(): 
		General.characters_with_bubble.erase(character_owner)
		queue_free())


func pop_up_bubble() -> void:
	var pop_up_tween : Tween = get_tree().create_tween()
	pop_up_tween.tween_property(self,"scale",BUBBLE_SCALE,1.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func set_random_bubble() -> void:
	scale = Vector3(0.0,0.0,0.0)
	var random_key : float = BUBBLE_OFFSET_TYPE_BUBBLE.keys().pick_random()
	booble_texture.set_texture(BUBBLE_OFFSET_TYPE_BUBBLE[random_key])
	local_bubble_pos.z = random_key
	call_deferred("try_set_emogi")
	


func try_set_emogi() -> void:
	var path_to_emogi : String = Caracters.EMOGI_PATH + character_owner.emogi
	path_to_emogi.replace(".import","")
	emoji_texture.set_texture(ResourceLoader.load(path_to_emogi))



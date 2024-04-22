extends CharacterBody3D
class_name Base_Character

@export var character_mesh : MeshInstance3D
@export var bone_for_hair : BoneAttachment3D
@export_enum("MALE","FEMALE") var gender : int
@export var anim_player : AnimationPlayer

@export_enum("LEFT","RIGHT") var diraction : int = 0
@onready var start_position : Vector3

@onready var emogi : String = get_parent().get_parent().arr_with_emogi.pick_random()

static var speed : float = 1.0

const FREE_FALL : float = -9.8

var character_properties : CharacterProperties
var character_image : Image = Image.new()
var character_imagetexture : ImageTexture = ImageTexture.new()


var vel : Vector3

const IMAGE_TEXTURE_SIZE : Vector2i = Vector2i(4,4)

const PARTS_OF_CHARACTER : Dictionary = {
"FOOT" : Vector2i(0,0),"CALF" : Vector2i(1,0),"KNEES" : Vector2i(2,0), "HAIR" : Vector2i(3,0),
"GROIN" : Vector2i(0,1), "HEAD" : Vector2i(1,1), "TORSO" : Vector2i(2,1),
"SHOULDER" : Vector2i(0,2), "ELBOW" : Vector2i(1,2), "WRIST" : Vector2i(2,2)}

func _ready() -> void:
	set_start_character_transform()
	texture_character_from_properties()
	set_proper_animation()


func set_proper_animation() -> void:
	match gender:
		0:
			anim_player.play("Male Walk")
		1:
			anim_player.play("Female Walk")


func _physics_process(delta):
	#velocity = vel
	move_and_slide()


func set_start_character_transform() -> void:
	if start_position:
		global_position = start_position
	if diraction == 1:
		set_rotation_degrees(Vector3(0.0,180.0,0.0))
		vel = Vector3(0.0,FREE_FALL,-speed)
		velocity = vel
		return
	vel = Vector3(0.0,FREE_FALL,speed)
	velocity = vel


func texture_character_from_properties() -> void:
	character_properties = CharacterProperties.create_random(gender)
	character_image = Image.create(IMAGE_TEXTURE_SIZE.x,IMAGE_TEXTURE_SIZE.y,false,Image.FORMAT_RGBA8)
	
	# fill texture with skin color
	character_image.fill(character_properties.skin_color)
	
	#setting hair color and foot
	character_image.set_pixelv(PARTS_OF_CHARACTER.HAIR,character_properties.hair_color)
	character_image.set_pixelv(PARTS_OF_CHARACTER.FOOT,character_properties.shoes_color)
	
	# seting top cloth
	character_image.set_pixelv(PARTS_OF_CHARACTER.TORSO,character_properties.color_top_cloth)
	
	if character_properties.top_cloth_lenth > 0:
		character_image.set_pixelv(PARTS_OF_CHARACTER.SHOULDER,character_properties.color_top_cloth)
		if character_properties.top_cloth_lenth > 1:
			character_image.set_pixelv(PARTS_OF_CHARACTER.ELBOW,character_properties.color_top_cloth)
	
	# seting bot cloth
	character_image.set_pixelv(PARTS_OF_CHARACTER.GROIN,character_properties.color_bot_cloth)
	
	if character_properties.bot_cloth_lenth> 0:
		character_image.set_pixelv(PARTS_OF_CHARACTER.KNEES,character_properties.color_bot_cloth)
		if character_properties.bot_cloth_lenth > 1:
			character_image.set_pixelv(PARTS_OF_CHARACTER.CALF,character_properties.color_bot_cloth)
	
	
	# adding hair
	var hair_scene : PackedScene = ResourceLoader.load(character_properties.hair_type)
	var hair_instance = hair_scene.instantiate()
	add_child(hair_instance)
	hair_instance.reparent(bone_for_hair)

	# seting material
	var character_material : ShaderMaterial = character_mesh.get_surface_override_material(0)
	hair_instance.get_child(0).set_surface_override_material(0,character_material)
	character_imagetexture = ImageTexture.create_from_image(character_image)
	character_material.set_shader_parameter("character_texture",character_imagetexture)
	
	
	
	
	

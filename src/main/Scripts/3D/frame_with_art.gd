extends Node3D

@onready var art_mesh_instance : MeshInstance3D = $picture_frame/art

@export var art_image : Image:
	set(value):
		art_image = value
		call_deferred("set_art",value)


func set_art(image : Image) -> void:
	var art_texture : ImageTexture = ImageTexture.create_from_image(image)
	art_mesh_instance.get_surface_override_material(0).set_shader_parameter("art_texture",art_texture)

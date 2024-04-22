extends Node

class_name Drawning

signal tile_drawen(tile_color : Color,tiles_count : int)
signal color_over(color : Color)
signal all_color_over

var art : PixelArtTexture = ArtStorage.current_art_texture

#Color : number
var color_number : Dictionary

#Color : number of tiles
var source_color_tiles_numbers : Dictionary

var progress_color_tiles_numbers : Dictionary

func _init() -> void:
	_get_color_number()


func _get_color_number() -> void:
	if color_number.is_empty() and source_color_tiles_numbers.is_empty():
		var number : int = 1
		var source_image : Image = art.get_source_image()
		
		for x in range(source_image.get_height()):
			for y in range(source_image.get_width()):
				var pixel_color : Color = source_image.get_pixel(x,y)
				
				if pixel_color.a < General.ALPHA_THRESHOLD:
					continue
				
				if not source_color_tiles_numbers.has(pixel_color):
					source_color_tiles_numbers[pixel_color] = 1
				else:
					source_color_tiles_numbers[pixel_color] += 1
				
				if not color_number.has(pixel_color):
					color_number[pixel_color] = number
					number += 1
		
		#TODO fix after continue drawing implementation
		progress_color_tiles_numbers = source_color_tiles_numbers.duplicate()
		
	else:
		push_error("dictionary not empty on _init")


func delete_tile_from_progres(color : Color, deleted_count : int) -> void:
	if progress_color_tiles_numbers[color] - deleted_count >= 0:
		progress_color_tiles_numbers[color] -= deleted_count
		tile_drawen.emit(color,deleted_count)
	else:
		push_error(progress_color_tiles_numbers[color]," < 0")
	
	check_for_color_over(color)


func check_for_color_over(color : Color) -> void:
	if progress_color_tiles_numbers[color] == 0:
		color_over.emit(color)
		progress_color_tiles_numbers.erase(color)
	if progress_color_tiles_numbers.is_empty():
		all_color_over.emit()
		LvlManager.lvl_complete()


func get_color_progress_index(color : Color) -> float:
	var already_painted_tiles : int = source_color_tiles_numbers[color] - progress_color_tiles_numbers[color]
	if already_painted_tiles == 0:
		return 1.0
	elif already_painted_tiles < 0:
		push_error("already_painted_tiles out of bounds")
		return -1.0
	else:
		var index_per_tile : float = get_index_per_tile(color)
		return 1.0 - (index_per_tile * float(already_painted_tiles))


func get_drawen_tiles(color : Color) -> int:
	return source_color_tiles_numbers[color] - (source_color_tiles_numbers[color] - progress_color_tiles_numbers[color])


func get_index_per_tile(color : Color) -> float:
	return 1.0 / float(source_color_tiles_numbers[color])

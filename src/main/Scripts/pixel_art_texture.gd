class_name PixelArtTexture

extends ImageTexture


#region properties
var path_to_source_png : String = ""
var path_to_progress_png : String = ""
var theme : String = ""
var progress_image : Image = Image.new()
var source_image : Image = Image.new()
#endregion


func create(path_to_source_image) -> void:
#TODO check path corectness
	if not ResourceLoader.exists(path_to_source_image):
		push_error("file not exists")
		return
	source_image = ResourceLoader.load(path_to_source_image)
	path_to_source_png = path_to_source_image
	theme = Path.get_last_folder_name(path_to_source_image)
	create_gray(path_to_source_image)
	set_image(progress_image)


func get_pixelart_name() -> String:
	return Path.get_file_name_without_extension(path_to_source_png)


func create_gray(path_to_source_png) -> void:
	if(path_to_source_png.is_empty()):
		push_error("path to source png is empty")
		pass
	var source_file_name = Path.get_file_name_without_extension(path_to_source_png)
	var path_to_progress_folder = Constants.FOLDERS.PROGRESS_PIXELARTS
	var gray_image_path = path_to_progress_folder + source_file_name + "_current.png"
	if not DirAccess.dir_exists_absolute(path_to_progress_folder):
		DirAccess.make_dir_absolute(path_to_progress_folder)
	if FileAccess.file_exists(gray_image_path): #if already exists gray\coloured a liitle bit image
		path_to_progress_png = gray_image_path
		progress_image.load(path_to_progress_png)
		pass
	else:
		print("Creating gray image of: " + source_file_name)
		# Load the original image
		var grayscale_image : Image = Image.new()
		grayscale_image.copy_from(source_image)
		grayscale_image = image_to_black_and_white(grayscale_image)
		
		# Save the grayscale image with a new path
		grayscale_image.save_png(gray_image_path)
		progress_image = grayscale_image
		path_to_progress_png = gray_image_path


static func image_to_black_and_white(image : Image,low_contrast : bool = false) -> Image:
		# Iterate through each pixel and convert to grayscale
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var color = image.get_pixel(x, y)
			if color.a > General.ALPHA_THRESHOLD:
				var gray_value = color.r * 0.299 + color.g * 0.587 + color.b * 0.114
				if low_contrast:
					gray_value = gray_value * 0.5 + 0.25
				image.set_pixel(x, y, Color(gray_value, gray_value, gray_value))
			else:
				image.set_pixel(x, y, Color(0.0,0.0,0.0,0.0))
	return image


func get_source_image()->Image:
	return source_image
	

func update_pixel(x:int,y:int, color: Color)->void:
	progress_image.set_pixel(x,y,color)
	update(progress_image)
	
	
func save_progress():
	progress_image.save_png(path_to_progress_png)
	

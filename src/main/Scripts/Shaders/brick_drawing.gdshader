shader_type canvas_item;
uniform sampler2D art_texture : filter_nearest, source_color;
uniform vec2 tile_count = vec2(5.0);
uniform vec2 viewport_size = vec2(1080, 1080);
uniform vec2 camera_position;
uniform float zoom = 1.0;

varying vec2 pixel_pos;

void vertex(){
	pixel_pos = VERTEX;
}

void fragment() {
	// Преобразование координат пикселя
	vec2 uv = pixel_pos / viewport_size;
	
	// **Смещение координат относительно центра экрана**
	uv -= camera_position / viewport_size;
	
	// **Масштабирование текстуры**
	uv /= zoom;
	
	// Вычисление координат текстуры с учетом тайлинга
	vec2 tiledUV = fract(uv * tile_count);
	
	// Получение цвета из текстуры
	COLOR = texture(art_texture, tiledUV);
}

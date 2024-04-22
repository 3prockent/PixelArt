extends CanvasLayer

class_name LoadingScreen

static var TIMER_WAIT_TIME = 1
static var LOADING_PHRASES : Dictionary= {
	25.0: "Creating pixelarts.",
	50.0: "Creating pixelarts..",
	75.0: "Creating pixelarts...",
	100.0: "Finalize",
}

@onready var progressBar : ProgressBar = $ColorRect/ProgressBar
@onready var label : Label = $ColorRect/Label


func _ready():
	_connect_signals()
	_start_callable_timer(1.0, _update_all_arts_in_thread, _on_update_timer_timeout)
	_start_callable_timer(0.5, _update_label_in_thread, _on_update_label_timeout)
	


func _connect_signals():
	ArtStorage.connect("progress_changed", _update_progress_bar)
	
	
func _start_callable_timer(wait_time:float, caller : Callable, handler : Callable):
	var thread = Thread.new()
	var timer = Timer.new()
	caller.call(thread)
	timer.wait_time = wait_time
	timer.timeout.connect(handler.bind(timer, thread, caller))
	timer.one_shot = true
	add_child(timer)
	timer.start()
	
	
func _update_all_arts_in_thread(thread : Thread):
	thread.start(ArtStorage.update_all_arts)
	
	
func _on_update_timer_timeout(timer : Timer, thread : Thread, caller : Callable ) -> void:
	if thread.is_alive():
		timer.start()
	else:
		get_tree().change_scene_to_packed(Constants.SCENES.MAIN_MENU)

func _on_update_label_timeout(timer : Timer, thread : Thread, caller : Callable):
	var progress_value : float = progressBar.get_value()
	var label_text : String = _get_label_text_by_range(progress_value)
	if progress_value<=100:
		label.text = label_text
		timer.start()
	
	
func _update_label_in_thread(thread : Thread):
	pass
	

func _get_label_text_by_range(value : float):
	for key in LOADING_PHRASES.keys():
		if value <= key:
			return LOADING_PHRASES[key]
	
func _update_progress_bar(new_value : float) ->void:
	progressBar.set_value_no_signal(new_value)
	
	
	

extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	SnapshotsClient.show_saved_games("test", true, true, 10)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

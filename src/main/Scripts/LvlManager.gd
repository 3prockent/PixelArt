extends Node

class_name LvlManager

const start_lvl : int = 1

static var current_lvl : int


static func lvl_complete() -> void:
	current_lvl += 1
	SaveManager._save()

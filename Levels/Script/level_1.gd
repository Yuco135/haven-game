class_name Level extends Node2D

func _ready() -> void:
	GameManager.set_level(self)
	
func _process(delta):
	Global.gameStarted = false

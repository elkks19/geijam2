extends Node

@onready var color: ColorRect = $"../ColorRect"

func _input(event):
	if event.is_action_pressed("player_use_camera"):
		color.visible = !color.visible
		

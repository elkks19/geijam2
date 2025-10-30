extends Node

@onready var color = $"../ColorRect"

func _input(event):
	if event.is_action_pressed("ui_accept"):
		color.visible = !color.visible
		

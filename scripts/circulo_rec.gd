extends TextureRect

var visible_state := true

func _ready() -> void:
	var timer := Timer.new()
	timer.wait_time = 0.5  # medio segundo
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func _on_timer_timeout() -> void:
	visible_state = !visible_state
	self.visible = visible_state

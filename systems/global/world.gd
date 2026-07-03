extends Node

var time_scale : float = 1:
	set(value):
		time_scale = clamp(value, 0.02, 1)

func get_time_scale() -> float:
	return time_scale
	
func set_time_scale(scale : float):
	time_scale = scale

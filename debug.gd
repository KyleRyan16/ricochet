extends Node3D

@export var show_fps : bool = false
@export var fps_refresh_rate : float = 0.5
var time_since_refresh : float = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if show_fps:
		time_since_refresh += delta
		if time_since_refresh >= fps_refresh_rate:
			time_since_refresh -= fps_refresh_rate
			print("fps: ", 1/delta)
	pass

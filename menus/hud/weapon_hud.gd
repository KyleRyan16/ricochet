extends Node3D

@export var weapon : Weapon = null
@onready var scene_anchor : Node3D = $"."
@onready var progress_bar : TextureProgressBar = $Control/TextureProgressBar

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	progress_bar.value = weapon.attack_cooldown / weapon.spec.attack_rate * 100
	progress_bar.position = get_viewport().get_camera_3d().unproject_position(scene_anchor.global_position)

extends CharacterBody3D

class_name InteractableEntity

func projectile_hit(_projectile : Node3D):
	destroy()

func destroy():
	queue_free()

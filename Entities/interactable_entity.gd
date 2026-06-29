extends CharacterBody3D

class_name InteractableEntity

func projectile_hit(projectile : Node3D):
	destroy()

func destroy():
	queue_free()

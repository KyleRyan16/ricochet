extends CharacterBody3D

class_name InteractableEntity

func projectile_hit(projectile : Node3D):
	destroy(projectile)

func destroy(destroyer : Node3D):
	print(destroyer)
	queue_free()

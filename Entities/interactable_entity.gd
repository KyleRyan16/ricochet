extends Node
	
func projectile_hit(projectile : Projectile):
	destroy(projectile)

func destroy(destroyer : Node3D):
	print(destroyer)
	queue_free()

extends CharacterBody3D

@onready var weapon_user : WeaponUser = $WeaponUser
	
func projectile_hit(projectile : Node3D):
	destroy(projectile)

func destroy(destroyer : Node3D):
	print(destroyer)
	queue_free()


func entity_sight_updated(entity: Node3D, can_see: bool):
	if !can_see:
		return
	look_at(entity.global_position)
	weapon_user.attack() 

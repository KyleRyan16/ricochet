extends Weapon

class_name ProjectileWeapon

@export var spawn_transform : Node3D

@export var projectile_spec : ProjectileSpec = null

func attack():
	fire()
	pass
	
func fire(): 
	var projectile := projectile_spec.projectile_scene.instantiate()
	
	projectile.position = spawn_transform.global_position
	projectile.rotation = spawn_transform.global_rotation
	get_tree().current_scene.add_child(projectile)
	projectile.init(projectile_spec)

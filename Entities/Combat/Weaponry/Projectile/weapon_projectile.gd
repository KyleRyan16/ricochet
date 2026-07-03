extends Weapon

class_name ProjectileWeapon

@export var spawn_transform : Node3D

func _do_attack():
	fire()

func fire():
	var projectile_spec := spec as ProjectileSpec
	var projectile := projectile_spec.projectile_scene.instantiate()
	
	projectile.position = spawn_transform.global_position
	projectile.rotation = spawn_transform.global_rotation
	get_tree().current_scene.add_child(projectile)
	projectile.init(projectile_spec)

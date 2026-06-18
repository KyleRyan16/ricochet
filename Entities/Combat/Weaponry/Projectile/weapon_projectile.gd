extends Weapon

class_name ProjectileWeapon

# A projectile weapon produces projectiles that travel through space
@export var projectile_scene : PackedScene

@export var spawn_transform : Node3D

@export var projectile_spec : ProjectileSpec = null

# speed in units/sec the projectile travels at
var speed : float = 10

func attack():
	fire()
	pass
	
func fire(): 
	var projectile : Projectile = projectile_scene.instantiate()
	
	projectile.position = spawn_transform.global_position
	projectile.rotation = spawn_transform.global_rotation
	get_tree().current_scene.add_child(projectile)
	projectile.init(projectile_spec)

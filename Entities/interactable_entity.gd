extends CharacterBody3D

@onready var weapon_user : WeaponUser = $WeaponUser

# per second
@export var attack_rate : float = 1
@export var delay_before_first_attack : float = 0.5
@onready var time_since_attack : float = -delay_before_first_attack + attack_rate

var target : Node3D = null
	
func projectile_hit(projectile : Node3D):
	destroy(projectile)

func destroy(destroyer : Node3D):
	print(destroyer)
	queue_free()
	
func _physics_process(delta: float) -> void:
	
	if target:
		look_at_target()
		time_since_attack += delta
		if time_since_attack >= attack_rate:
			time_since_attack = 0
			weapon_user.attack()

func look_at_target():
	if !target:
		return
	
	var target_position = target.global_position
	target_position.y = global_position.y
	look_at(target_position)

func entity_sight_updated(entity: Node3D, can_see: bool):
	if !can_see:
		target = null
		return
	target = entity

extends Node

class_name Weapon

@export var spec : WeaponSpec = null

var attack_cooldown : float = 0

var is_attacking : bool = false

# A weapon is used to attack

func _process(delta: float) -> void:
	delta *= World.get_time_scale()
	if attack_cooldown > 0:
		attack_cooldown = max(attack_cooldown - delta, 0)

# one-off attack
func attack():
	if !can_attack():
		return
	is_attacking = true
	_do_attack()
	attack_cooldown = spec.attack_rate
	is_attacking = false
	pass

# begin a continous/repeatable attack
func begin_attack():
	if !can_attack():
		return
	is_attacking = true
	pass

# end the current attack
func end_attack():
	if can_attack():
		return
	is_attacking = false
	pass

# stub for weapons to define what an attack is
func _do_attack():
	pass
	
func can_attack():
	return !is_attacking && attack_cooldown <= 0

extends Node

class_name WeaponUser

# Uses a weapon to attack

# TODO: support multiple weapons
@export var weapon : Weapon = null

func attack():
	if !weapon.can_attack():
		return
	weapon.attack()

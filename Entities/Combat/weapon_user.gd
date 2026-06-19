extends Node

class_name WeaponUser

# Uses a weapon to attack

# TODO: support multiple weapons
@export var weapon : Weapon = null
	
func attack():
	weapon.attack()

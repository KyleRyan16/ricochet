extends Node

class_name WeaponUser

# Uses a weapon to attack

# TODO: support multiple weapons
@onready var weapon : Weapon = $ProjectileWeapon
	
func attack():
	weapon.attack()

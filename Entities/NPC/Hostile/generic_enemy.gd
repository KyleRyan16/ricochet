extends InteractableEntity

@onready var weapon_user : WeaponUser = $WeaponUser

@onready var move_speed : float = 2

## per second
@export var attack_rate : float = 1
@export var delay_before_first_attack : float = 0.5
@onready var time_since_attack : float = -delay_before_first_attack + attack_rate

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D

var target : Node3D = null
var poi : Vector3

func _ready() -> void:
	poi = global_position
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 4
	

	
func _physics_process(delta: float) -> void:
	
	set_movement_target()
	look_at_target()
	if target:
		time_since_attack += delta
		if time_since_attack >= attack_rate:
			time_since_attack = 0
			#weapon_user.attack()
			
	if !nav_agent.is_navigation_finished():
		var next_path_position: Vector3 = nav_agent.get_next_path_position()
		velocity = global_position.direction_to(next_path_position) * move_speed
		move_and_slide()
		

func set_movement_target():
	if target:
		poi = target.global_position
	nav_agent.set_target_position(poi)

func look_at_target():
	var pos : Vector3 = target.global_position if target else poi
	pos.y = global_position.y
	if pos == global_position:
		return
	look_at(pos)

func entity_sight_updated(entity: Node3D, can_see: bool):
	if !can_see:
		poi = entity.global_position
		nav_agent.target_desired_distance = 0.5
		target = null
		return
	target = entity
	nav_agent.target_desired_distance = 4

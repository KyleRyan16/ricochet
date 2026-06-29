extends InteractableEntity

@onready var weapon_user : WeaponUser = $WeaponUser

@onready var mesh : Dissolvable = $Dissolvable

@onready var move_speed : float = 2

## per second
@export var attack_rate : float = 1
@export var delay_before_first_attack : float = 0.5
@onready var time_since_attack : float = -delay_before_first_attack + attack_rate

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D

@export var path_update_rate : float = 0.5
@onready var time_since_last_path : float = path_update_rate

var is_alive : bool = true

var target : Node3D = null
var poi : Vector3

func _ready() -> void:
	poi = global_position
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 4

func _physics_process(delta: float) -> void:
	
	if !is_alive:
		return
	
	DebugDraw3D.draw_sphere(poi, 0.5, Color.YELLOW)
	
	look_at_target()
	if target:
		time_since_attack += delta
		if time_since_attack >= attack_rate:
			time_since_attack = 0
			#weapon_user.attack()
	
	time_since_last_path += delta
	if time_since_last_path >= path_update_rate:
		set_movement_target()
		time_since_last_path -= path_update_rate
	
		if !nav_agent.is_navigation_finished():
			var next_path_position: Vector3 = nav_agent.get_next_path_position()
			var new_velocity = global_position.direction_to(next_path_position) * move_speed
			if nav_agent.avoidance_enabled:
				nav_agent.velocity = new_velocity
			else:
				on_velocity_computed(new_velocity)
	
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
		nav_agent.target_desired_distance = 0.1
		target = null
		return
	target = entity
	nav_agent.target_desired_distance = 4
	time_since_last_path = path_update_rate


func on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	
func projectile_hit(projectile : Node3D):
	if !is_alive:
		return
	is_alive = false
	mesh.dissolve_finished.connect(destroy)
	mesh.dissolve(projectile.global_position)

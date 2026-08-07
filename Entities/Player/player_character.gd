extends CharacterBody3D

@onready var pause_menu := $"../../PauseMenu"

@onready var aim_solver : AimSolver = $AimSolver
@onready var weapon_user : WeaponUser = $WeaponUser
@onready var mesh : Dissolvable = $CollisionShape3D/Dissolvable

@export var aim_distance_simulation : float = 15
@export var aim_simulation_bounces : int = 3

const SPEED = 10.0
const JUMP_VELOCITY = 4.5

var is_alive : bool = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		weapon_user.attack()
	if	event.is_action_pressed("pause_menu"):
		pause_menu.toggle()
		


func _physics_process(delta: float) -> void:
	
	if !is_alive:
		return;
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if !input_dir:
		World.set_time_scale(move_toward(World.get_time_scale(), 0, 0.02))
	else:
		World.set_time_scale(move_toward(World.get_time_scale(), input_dir.length(), 0.01))
	delta *= World.get_time_scale()
	
	var aim_position := aim_solver.get_mouse_aim_position(global_position)
	
	look_at(aim_position, Vector3.UP)
	var bounce_count : int = min(aim_simulation_bounces, weapon_user.weapon.spec.max_ricochets)
	var result : AimSolver.TrajectoryResult = AimSolver.TrajectoryResult.Init(bounce_count)
	AimSolver.simulate_trajectory(self, global_position, -basis.z, aim_distance_simulation, result)
	
	var start_position = global_position
	for move in result.movements:
		DebugDraw3D.draw_arrow(start_position, start_position + move, Color.RED, 0.5, true)
		start_position += move
		
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if direction:
		velocity.x = direction.x * SPEED * delta * 60
		velocity.z = direction.z * SPEED * delta * 60
	else:
		velocity.x = velocity.x * delta * 60
		velocity.z = velocity.z * delta * 60

	move_and_slide()

func projectile_hit(projectile : Node3D):
	if !is_alive:
		return
	is_alive = false
	mesh.dissolve_finished.connect(destroy)
	mesh.dissolve(projectile.global_position)

func destroy():
	queue_free()

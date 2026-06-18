extends CharacterBody3D

@onready var aim_solver : AimSolver = $"../AimSolver"
@onready var weapon_user : WeaponUser = $"../WeaponUser"

@export var aim_distance_simulation : float = 15
@export var aim_simulation_bounces : int = 3

const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Attack"):
		weapon_user.attack()


func _physics_process(delta: float) -> void:
	
	var aim_position := aim_solver.get_mouse_aim_position(global_position)
	
	look_at(aim_position, Vector3.DOWN)
	var result : AimSolver.TrajectoryResult = AimSolver.TrajectoryResult.Init(aim_simulation_bounces)
	AimSolver.simulate_trajectory(self, -basis.z, aim_distance_simulation, result)
	
	var start_position = global_position
	for move in result.movements:
		DebugDraw3D.draw_arrow(start_position, start_position + move, Color.RED, 0.5, true)
		start_position += move
		
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func projectile_hit(projectile : Projectile):
	destroy(projectile)

func destroy(destroyer : Node3D):
	print(destroyer)
	queue_free()

extends AnimatableBody3D

class_name Projectile

# A projectile is comprised of a line raycast searching for richochets off walls
# and the collision shape that will "sweep" for targets along the way

var spec : ProjectileSpec = null

var bounces : int = 0

var array : Array[Vector3]

func _ready() -> void:
	set_physics_process(false)
	pass

func init(new_spec : ProjectileSpec):
	spec = new_spec
	bounces = spec.max_ricochets
	set_physics_process(true)

func _physics_process(delta: float) -> void:

	var result : AimSolver.TrajectoryResult = AimSolver.TrajectoryResult.Init(bounces)
	AimSolver.simulate_trajectory(self, -basis.z, spec.distance * delta, result)
	for move in result.movements:
		look_at(global_position + move)
		move_and_collide(move, false, 0.001, false, 100)
	bounces = result.bounces
	
	if bounces < 0:
		queue_free()

func body_entered(body: Node3D) -> void:
	print(body)
	if body.has_method("projectile_hit"):
		body.projectile_hit(self)
		
	var parent = body.get_parent_node_3d()
	if parent && parent.has_method("projectile_hit"):
		parent.projectile_hit(self)

func area_entered(area: Area3D) -> void:
	print(area)
	if area.has_method("projectile_hit"):
		area.projectile_hit(self)
	
	var parent = area.get_parent_node_3d()
	if parent && parent.has_method("projectile_hit"):
		parent.projectile_hit(self)

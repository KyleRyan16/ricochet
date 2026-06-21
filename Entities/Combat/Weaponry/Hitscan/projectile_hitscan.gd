extends Node3D

class_name HitscanProjectile

# how long the hitscan persists, not just visually
@export var lifetime : float = 1

# Called when the node enters the scene tree for the first time.
func init(new_spec : ProjectileSpec) -> void:
	var result : AimSolver.TrajectoryResult = AimSolver.TrajectoryResult.Init(new_spec.max_ricochets)
	AimSolver.simulate_trajectory(self, -basis.z, new_spec.distance, result)
	var position : Vector3 = global_position
	for move in result.movements:
		var end : Vector3 = position + move
		
		# create the Aread3D and position it accordingly
		var area : Area3D = Area3D.new()
		add_child(area)
		area.global_position = position + move/2
		area.look_at(end)
		area.collision_mask = 1 << 2
		
		# create the CollisionShape and scale accordingly
		var collider : CollisionShape3D = CollisionShape3D.new()
		var collider_shape : CapsuleShape3D = CapsuleShape3D.new()
		collider_shape.height = move.length()
		collider.shape = collider_shape

		collider.rotation_degrees.x += -90
		
		area.add_child(collider)
		area.body_entered.connect(entered)
		area.area_entered.connect(entered)

		position += move
		
func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
		
func entered(node : Node3D):
	print(node)
	if node.has_method("projectile_hit"):
		node.projectile_hit(self)
		
	var parent = node.get_parent_node_3d()
	if parent && parent.has_method("projectile_hit"):
		parent.projectile_hit(self)

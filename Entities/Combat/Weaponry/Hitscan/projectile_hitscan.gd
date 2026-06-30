extends Node3D

class_name HitscanProjectile

# how long the hitscan persists, not just visually
@export var lifetime : float = 1

@onready var area : Area3D = $Area

@export var laser_segment_scene : PackedScene = null

# Called when the node enters the scene tree for the first time.
func init(new_spec : ProjectileSpec) -> void:
	var result : AimSolver.TrajectoryResult = AimSolver.TrajectoryResult.Init(new_spec.max_ricochets)
	AimSolver.simulate_trajectory(self, global_position, -basis.z, new_spec.distance, result)
	var position : Vector3 = global_position
	for move in result.movements:
		var previous : Vector3 = position
		var current : Vector3 = previous + move
		var segment := add_segment(current, previous)
		
		segment.init(current, previous)
		area.add_child(segment)
		segment.global_position = current
		segment.look_at(current + (current - previous).normalized())
		position += move
		
		
func add_segment(head_pos : Vector3, tail : Vector3) -> LaserSegment:
	var segment : LaserSegment = laser_segment_scene.instantiate()
	
	
	return segment
		
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

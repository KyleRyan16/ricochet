extends Node3D

class_name LaserPath

@export var laser_segment_scene : PackedScene = null

var segments : Array[LaserSegment]

# visualises the path of a laser and its trail, optionally with collision

var spec : ProjectileSpec = null
var bounces : int = 0

## Length of the trail
@export var max_length : float = 15

func _physics_process(delta: float) -> void:
	
	if bounces < 0:
		# bounces are used up, but laser tail still needs to finish
		max_length -= spec.distance * delta
		shrink_tail()
		if segments.is_empty():
			queue_free()
		return
	
	var result : AimSolver.TrajectoryResult = AimSolver.TrajectoryResult.Init(bounces)
	AimSolver.simulate_trajectory(self, get_head_pos(), get_direction(), spec.distance * delta, result)
	
	if segments.is_empty():
		add_segment(result.movements[0] + global_position, get_direction())
		result.movements.remove_at(0)

	var movements := result.movements
	for i in range(0, movements.size()):
		if i > 0:
			add_segment(get_head().head + movements[i], movements[i].normalized())
			continue
		var segment := get_head()
		segment.update(movements[i], max_length)
	
	shrink_tail()
	
	bounces = result.bounces
	
func init(new_spec : ProjectileSpec):
	spec = new_spec
	bounces = spec.max_ricochets

func get_head_pos() -> Vector3:
	return segments[segments.size() -1].global_position if !segments.is_empty() else global_position
	
func get_head() -> LaserSegment:
	return segments[segments.size() -1] if !segments.is_empty() else null
	
func get_direction() -> Vector3:
	var head := get_head()
	if head:
		return -head.global_transform.basis.z
	return -global_transform.basis.z

func add_segment(head_pos : Vector3, head_dir : Vector3):
	var prev_pos : Vector3 = get_head_pos()
	
	var segment : LaserSegment = laser_segment_scene.instantiate()
	segment.init(head_pos, prev_pos)
	add_child(segment)
	segment.global_position = head_pos
	segment.look_at(head_pos + head_dir)
	segments.append(segment)
	
func shrink_tail():
	var current_length : float = 0
	for segment in segments:
		current_length += segment._length
	
	var shrink : float = current_length - max_length
	while shrink > 0 && !segments.is_empty():
		var segment := segments[0]
		if shrink >= segment._length:
			segments.remove_at(0)
			shrink -= segment._length
			segment.queue_free()
		else:
			segment.update(Vector3(0,0,0), segment._length - shrink)
			shrink = 0

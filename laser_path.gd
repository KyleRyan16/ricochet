extends Path3D

class_name LaserPath

var yep : ArrayMesh

# visualises the path of a laser and its trail, optionally with collision

var spec : ProjectileSpec = null

var bounces : int = 0

@onready var path : Curve3D = Curve3D.new()

## Length of the trail
@export var length : float = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curve = path
	
	# add two points so we have an initial path to work with
	add_point(Vector3(0,0,0))
	add_point(Vector3(10,0,0))
	
	await get_tree().create_timer(1).timeout
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	
	if bounces < 0:
		# bounces are used up, but laser tail still needs to finish	
		return
	
	var result : AimSolver.TrajectoryResult = AimSolver.TrajectoryResult.Init(bounces)
	var head_point : Vector3 = path.get_point_position(path.point_count -1)
	var prev_point : Vector3 = path.get_point_position(path.point_count -2)
	
	AimSolver.simulate_trajectory(self, head_point + global_position, (head_point - prev_point).normalized(), spec.distance * delta, result)
	for move in result.movements:
		update_path(head_point + global_position + Vector3(1,1,0))
		
		
	bounces = result.bounces
	
func init(new_spec : ProjectileSpec):
	spec = new_spec
	bounces = spec.max_ricochets

func add_point(point_pos : Vector3):
	path.add_point(point_pos - global_position)

## Updates the position of the head, shrinking the tail when necessary
## assumes no new points, you must add_point() before or after
func update_path(new_position : Vector3):
	path.set_point_position(path.point_count -1, new_position - global_position)

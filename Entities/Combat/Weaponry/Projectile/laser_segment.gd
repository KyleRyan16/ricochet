extends Area3D

class_name LaserSegment

var _length : float = 0

@onready var collider : CollisionShape3D = $Collision
@onready var mesh : MeshInstance3D = $Mesh
@onready var impact_mesh : MeshInstance3D = $ImpactMesh

@export var desired_radius : float = 0.1

var head : Vector3
var tail : Vector3

func _ready() -> void:
	update_shapes()

func init(new_head : Vector3, new_tail : Vector3):
	_length = (new_head - new_tail).length()
	head = new_head
	tail = new_tail

func update(movement : Vector3, length : float):
	global_position += movement
	head = global_position
	tail = get_new_tail(length)
	_length = (head - tail).length()
	update_shapes()

func update_shapes():
	collider.shape.height = _length
	collider.shape.radius = min(_length / 2, desired_radius)
	collider.position.z = _length / 2
	mesh.mesh.height = _length
	mesh.mesh.radius = min(_length / 2, desired_radius)
	mesh.position.z = _length / 2
	
	impact_mesh.mesh.radius = min(_length / 2, desired_radius * 2)
	impact_mesh.mesh.height = min(_length / 2, desired_radius * 4)
	
func get_new_tail(new_length : float) -> Vector3:
	var diff := head - tail
	var dir := diff.normalized()
	var curr_length = diff.length()
	if new_length >= curr_length:
		return tail

	var new_tail := head - dir * new_length
	return new_tail


func entity_entered(body: Node3D) -> void:
	print(body)
	if body.has_method("projectile_hit"):
		body.projectile_hit(self)
		
	var parent = body.get_parent_node_3d()
	if parent && parent.has_method("projectile_hit"):
		parent.projectile_hit(self)

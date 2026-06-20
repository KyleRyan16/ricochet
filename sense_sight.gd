@tool
extends Area3D

class_name Sense_Sight

signal entity_sight_updated(entity : Node3D, can_see : bool)

class VisionStatus:
	var entity : Node3D = null
	var seen : bool = false
	static func create(new_entity : Node3D) -> VisionStatus:
		var vision_status := VisionStatus.new()
		vision_status.entity = new_entity
		return vision_status

@onready var visual_cone : MeshInstance3D = $MeshInstance3D
@onready var collider : CollisionShape3D = $CollisionShape3D
@onready var shape : SphereShape3D = collider.shape as SphereShape3D

@export var fov : float = 130
@export var radius : float = 5
@export var subdivisions : int = 12

# entities in range that aren't necessarily detected
var detectable_entities : Dictionary[int, VisionStatus]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	construct_vision_field(fov, radius, subdivisions)
	
	shape.radius = radius
	pass # Replace with function body.
	
func construct_vision_field(new_fov: float, new_radius: float, new_subdivisions: int):
	fov = new_fov
	radius = new_radius
	subdivisions = new_subdivisions
	
	var surface := SurfaceTool.new()
	var step : float = deg_to_rad(fov * 1/subdivisions)
	var rad : float = deg_to_rad(-fov / 2)
	
	var previous = get_point_position(rad)

	var center := Vector3.ZERO
	
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in range(subdivisions):
		rad += step
		var current : Vector3 = get_point_position(rad)
		surface.add_vertex(center)
		surface.add_vertex(previous)
		surface.add_vertex(current)
		previous = current

	visual_cone.mesh = surface.commit()
	
	shape.radius = radius
	
func get_point_position(angle_rad : float) -> Vector3:
	return Vector3(
		radius * sin(angle_rad),
		0,
		radius * -cos(angle_rad)
	)
	
func _physics_process(delta: float) -> void:
	for status in detectable_entities.values():
		var entity : Node3D = status.entity
		
		var forward := -global_transform.basis.z.normalized()
		var dir := (entity.global_transform.origin - global_transform.origin).normalized()
		var angle := acos(clamp(forward.dot(dir), -1.0, 1.0))
		
		var rad := deg_to_rad(fov/2)
		if angle >=  rad:
			if status.seen == true:
				status.seen = false
				entity_sight_updated.emit(entity, status.seen)
			continue
		
		
		var space := get_world_3d().direct_space_state
		
		var start = Vector3(global_position.x, entity.global_position.y, global_position.z)
		var end = entity.global_position
		var mask : int = 1
		var query = PhysicsRayQueryParameters3D.create(start, end, mask, [self])
		
		var result := space.intersect_ray(query)
		
		if !result:
			DebugDraw3D.draw_arrow(start, end, Color.BLUE, 0.5, true)
			DebugDraw3D.draw_sphere(end, 0.5, Color.RED)
			if status.seen == true:
				status.seen = false
				entity_sight_updated.emit(entity, status.seen)
			continue
		
		if result.collider == entity:
			DebugDraw3D.draw_sphere(result.position, 0.5, Color.GREEN)
			if status.seen == false:
				status.seen = true
				entity_sight_updated.emit(entity, status.seen)
		else:
			if status.seen == true:
				status.seen = false
				entity_sight_updated.emit(entity, status.seen)
			DebugDraw3D.draw_sphere(result.position, 0.5, Color.RED)
		DebugDraw3D.draw_arrow(start, result.position, Color.BLUE, 0.5, true)


func body_entered(body: Node3D) -> void:
	detectable_entities[body.get_instance_id()] = VisionStatus.create(body)

func body_exited(body: Node3D) -> void:
	detectable_entities.erase(body.get_instance_id())

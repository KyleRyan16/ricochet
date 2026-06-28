extends Area3D
class_name Sense_Sight

# Sees perceivalble entities.
# Has an inner radius to start perceving, and an outer radius for retaining perception

signal entity_sight_updated(entity : Node3D, can_see : bool)

class VisionStatus:
	var entity : Node3D = null
	var seen : bool = false
	static func create(new_entity : Node3D) -> VisionStatus:
		var vision_status := VisionStatus.new()
		vision_status.entity = new_entity
		return vision_status

@onready var inner : CollisionShape3D = $InnerRadius
@onready var outer : CollisionShape3D = $OuterRadius

@onready var visual_cone : MeshInstance3D = $VisualCone

@onready var inner_shape : SphereShape3D = inner.shape as SphereShape3D
@onready var outer_shape : SphereShape3D = outer.shape as SphereShape3D

@export var fov : float = 60
@export var inner_radius : float = 5
@export var outer_radius : float = 10
@export var subdivisions : int = 12

@export_flags_3d_physics var sight_mask : int = 0

# entities in range that aren't necessarily detected
var detectable_entities : Dictionary[int, VisionStatus]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	construct_vision_field(fov, inner_radius, outer_radius, subdivisions)
	
	inner_shape.radius = inner_radius
	outer_shape.radius = outer_radius
	pass # Replace with function body.
	
func construct_vision_field(new_fov: float, new_inner: float, new_outer: float, new_subdivisions: int):
	fov = new_fov
	inner_shape.radius = new_inner
	outer_shape.radius = new_outer
	subdivisions = new_subdivisions
	
	var surface := SurfaceTool.new()
	var step : float = deg_to_rad(fov * 1/subdivisions)
	var rad : float = deg_to_rad(-fov / 2)
	
	var global_pos := visual_cone.global_position
	
	var previous = get_point_position(rad)
	var global_previous : Vector3 = previous.rotated(global_transform.basis.y, global_transform.basis.get_euler().y) + global_pos

	var center := Vector3.ZERO
	var global_center : Vector3 = center.rotated(global_transform.basis.y, global_transform.basis.get_euler().y) + global_pos
	
	previous = (AimSolver.find_blocking(self, global_center, global_previous) - global_pos).rotated(global_transform.basis.y, -global_transform.basis.get_euler().y)

	surface.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in range(subdivisions):
		rad += step
		var current : Vector3 = get_point_position(rad)
		var global_current : Vector3 = current.rotated(global_transform.basis.y, global_transform.basis.get_euler().y) + global_pos
		
		surface.add_vertex(center)
		surface.add_vertex(previous)
		
		current = (AimSolver.find_blocking(self, global_center, global_current) - global_pos).rotated(global_transform.basis.y, -global_transform.basis.get_euler().y)
		
		
		surface.add_vertex(current)
		previous = current
		
	visual_cone.mesh = surface.commit()
	
func get_point_position(angle_rad : float) -> Vector3:
	return Vector3(
		inner_shape.radius * sin(angle_rad),
		0,
		inner_shape.radius * -cos(angle_rad)
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
		var query = PhysicsRayQueryParameters3D.create(start, end, sight_mask, [self])
		
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

func _process(delta: float) -> void:
	construct_vision_field(fov, inner_radius, outer_radius, subdivisions)

func body_entered(body: Node3D) -> void:
	detectable_entities[body.get_instance_id()] = VisionStatus.create(body)

func _on_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	var local_shape_owner = shape_find_owner(local_shape_index)
	var local_shape_node : Node3D = shape_owner_get_owner(local_shape_owner)
	if local_shape_node == inner:
		detectable_entities[body.get_instance_id()] = VisionStatus.create(body)

func _on_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	var local_shape_owner = shape_find_owner(local_shape_index)
	var local_shape_node : Node3D = shape_owner_get_owner(local_shape_owner)
	
	if !body:
		return
	
	var entity : VisionStatus = detectable_entities.get(body.get_instance_id())
	
	if !entity:
		assert(local_shape_node != inner, "entity left inner radius without having been a detectable entity!")
		return
		
	if local_shape_node == outer:
		entity_sight_updated.emit(entity.entity, false)
		detectable_entities.erase(body.get_instance_id())

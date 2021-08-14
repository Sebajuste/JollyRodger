class_name WaterFloater
extends Spatial

# https://www.youtube.com/watch?v=eL_zHQEju8s

var inwater_material = preload("floater_inwater.material")
var inair_material = preload("floater_inair.material")


export var water_drag := 2.0 # 0.99
export var water_angular_drag := 2.0 # 0.5

export var depth_before_submerged := 2.5
export var displacement_amount := 0.5

export var debug := false setget set_debug


var rigid_body : RigidBody
var floater_count := 1
var water_manager = null

var immerged := false


var water_surface := Vector3.ZERO
var archimed_force := Vector3.ZERO
var gravity := Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var oceans := get_tree().get_nodes_in_group("water_mesh")
	if not oceans.empty():
		water_manager = oceans[0]
	
	rigid_body = _get_rigidbody_parent(self)
	set_debug(debug)
	


func _get_rigidbody_parent(node : Node) -> Node:
	if not node:
		return null
	if node is RigidBody:
		return node
	return _get_rigidbody_parent(node.get_parent())


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _physics_process(delta : float):
	
	if not rigid_body:
		push_error("No Rigid Body parent for floater")
		return
	
	var floater_offset := self.global_transform.origin - rigid_body.global_transform.origin
	
	gravity = ( (get_gravity() * rigid_body.mass) / floater_count ) * delta
	
	rigid_body.apply_impulse(
		floater_offset,
		( (get_gravity() * rigid_body.mass) / floater_count ) * delta
	)
	
	var depth := get_water_height() - self.global_transform.origin.y
	
	if depth > 0:
		immerged = true
		
		var displacement_multiplier := get_displacement_multiplier(depth) * delta
		
		water_surface = Vector3(0, depth, 0)
		archimed_force = Vector3.UP * abs(get_gravity().y * rigid_body.mass) * (displacement_multiplier / floater_count)
		
		rigid_body.apply_impulse(
			floater_offset,
			Vector3.UP * abs(get_gravity().y * rigid_body.mass) * (displacement_multiplier / floater_count)
		)
		
		rigid_body.apply_impulse(
			Vector3.ZERO,
			(displacement_multiplier / floater_count) * -rigid_body.linear_velocity * water_drag
		)
		
		rigid_body.add_torque( (displacement_multiplier / floater_count) * -rigid_body.angular_velocity * water_angular_drag)
		
	else:
		water_surface = Vector3.ZERO
		archimed_force = Vector3.ZERO
		immerged = false


func get_displacement_multiplier(depth : float) -> float:
	
	return clamp(depth / depth_before_submerged, 0.0, 1.0) * displacement_amount
	


func get_water_height() -> float:
	
	if not water_manager:
		push_error("No water manager for floater")
		return 0.0
	
	return water_manager.get_wave_height(self.global_transform.origin)


func get_gravity() -> Vector3:
	
	return ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")
	


func set_debug(value):
	debug = value
	if DebugOverlay and DebugOverlay.vector:
		if debug:
			DebugOverlay.vector.add_vector(self, "water_surface", 1.0, 2.0, Color.darkblue)
			DebugOverlay.vector.add_vector(self, "archimed_force", 1.0, 2.0, Color.dodgerblue)
			DebugOverlay.vector.add_vector(self, "gravity", 1.0, 2.0, Color.red)
		else:
			DebugOverlay.vector.remove_vector(self, "water_surface")
			DebugOverlay.vector.remove_vector(self, "archimed_force")
			DebugOverlay.vector.remove_vector(self, "gravity")

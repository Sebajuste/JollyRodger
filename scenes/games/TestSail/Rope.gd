extends Spatial

const gravity := 9.8

export(NodePath) var from_path
export(NodePath) var to_path
export var dynamic := false
export var tightness := 1.0
export var damp := 1.0
export var length := 1.0


onready var from : Spatial = get_node(from_path)
onready var to : Spatial = get_node(to_path)


var spring
var from_spring_node
var to_spring_node


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	
	if dynamic:
		
		if from.is_in_group("cloth_support"):
			from_spring_node = from.get_spring_node()
		else:
			from_spring_node = Spring.SpringNode.new(from.global_transform.origin - to.global_transform.origin, false)
		
		if to.is_in_group("cloth_support"):
			to_spring_node = to.get_spring_node()
		else:
			to_spring_node = Spring.SpringNode.new(to.global_transform.origin, false)
		
		spring = Spring.new(from_spring_node, to_spring_node, tightness, damp, length)
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(_delta):
	
	if spring:
		
		var spring_vector : Vector3 = spring.a.position - spring.b.position
		
		var dir := spring_vector.normalized()
		
		#var relative_velocity := (spring_vector - last_spring_vector)
		#last_spring_vector = spring_vector
		
		var desired_distance := dir * length
		spring.a.position = desired_distance
		spring.a.velocity = Vector3.ZERO
		"""
		var x := (spring_vector - desired_distance)
		
		var f = -tightness * x - damp * relative_velocity
		
		if a.dynamic:
			a.velocity += f * delta
			a.position += a.velocity * delta
		else:
			a.velocity = Vector3.ZERO
		"""
	#	spring.update(delta)
	
	self.look_at_from_position(from.global_transform.origin, to.global_transform.origin, Vector3.UP)
	
	var distance : float = from.global_transform.origin.distance_to(to.global_transform.origin)
	
	#$MeshInstance.mesh.size.x = distance
	$MeshInstance.mesh.height = distance
	$MeshInstance.transform.origin.z = -distance/2
	

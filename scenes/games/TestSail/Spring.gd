class_name Spring
extends Object



class SpringNode:
	var position : Vector3
	var velocity : Vector3
	var dynamic : bool
	
	func _init(_position : Vector3, _dynamic := true):
		position = _position
		velocity = Vector3.ZERO
		dynamic = _dynamic


var a
var b
var tightness : float
var damp : float
var length : float


var last_spring_vector : Vector3


func _init(_a , _b, _tightness: float, _damp : float):
	a = _a
	b = _b
	tightness = _tightness
	damp = _damp
	length = a.position.distance_to(b.position)
	last_spring_vector = a.position - b.position


func update(delta : float):
	
	if not a.dynamic and not b.dynamic:
		return
	
	var spring_vector : Vector3 = a.position - b.position
	
	var dir := spring_vector.normalized()
	
	var relative_velocity := (spring_vector - last_spring_vector)
	last_spring_vector = spring_vector
	
	var desired_distance := dir * length
	
	var x := (spring_vector - desired_distance)
	
	var f = -tightness * x - damp * relative_velocity
	
	if a.dynamic:
		a.velocity += f * delta
		a.position += a.velocity * delta
	else:
		a.velocity = Vector3.ZERO
	
	if b.dynamic:
		b.velocity += -f * delta
		b.position += b.velocity * delta
	else:
		b.velocity = Vector3.ZERO

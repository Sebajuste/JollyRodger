# spring.gd
class_name SailSpring
extends Reference


var a : SailSpringBound
var b : SailSpringBound
var tightness : float
var damp : float
var length : float
var last_spring_vector : Vector3


func _init(_a : SailSpringBound, _b : SailSpringBound, _tightness: float, _damp : float, _length := -1.0):
	a = _a
	b = _b
	tightness = _tightness
	damp = _damp
	if _length > 0.0:
		length = _length
	else:
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

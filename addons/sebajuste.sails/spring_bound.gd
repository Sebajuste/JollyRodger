# spring_bound.gd
class_name SailSpringBound
extends Reference


var position : Vector3
var velocity : Vector3
var dynamic : bool

func _init(_position : Vector3, _dynamic := true):
	position = _position
	velocity = Vector3.ZERO
	dynamic = _dynamic

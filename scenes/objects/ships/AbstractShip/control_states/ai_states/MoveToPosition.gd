extends ShipState


signal position_reached


var move_position : Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func enter(msg : Dictionary = {}):
	
	if msg.has("move_position"):
		move_position = msg.move_position
	else:
		_state_machine.transition_to("AvoidObstacle/Idle")
	


func exit():
	
	_parent.chosen_direction = Vector3.ZERO
	


func process(delta):
	
	var position : Vector3 = ship.global_transform.origin
	
	var distance_squared := position.distance_squared_to(move_position)
	
	if distance_squared < 30*30:
		_state_machine.transition_to("AvoidObstacle/Idle")
		emit_signal("position_reached")
	
	_parent.process(delta)
	


func physics_process(delta):
	
	var position_delta := move_position - ship.global_transform.origin
	
	_parent.chosen_direction = position_delta.normalized()
	
	_parent.physics_process(delta)
	

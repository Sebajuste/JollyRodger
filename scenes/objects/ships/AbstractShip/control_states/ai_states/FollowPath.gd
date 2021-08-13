extends ShipState



var patrol_points : PoolVector3Array
var patrol_index := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func enter(msg := {}):
	
	if msg.has("curve"):
		patrol_points = msg.curve.get_baked_points()
	if msg.has("reset") and msg.reset:
		patrol_index = 0


func process(_delta):
	
	if not patrol_points or patrol_points.empty():
		_state_machine.transition_to("AvoidObstacle/Idle")
		return
	
	var position : Vector3 = ship.global_transform.origin
	var target := patrol_points[patrol_index]
	var distance_squared := position.distance_squared_to(target)
	
	if distance_squared < 30*30:
		while position.distance_squared_to(target) < 40*40:
			patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
			target = patrol_points[patrol_index]
	
	_state_machine.transition_to("AvoidObstacle/MoveToPosition", {
		"move_position": target
	})
	
	pass

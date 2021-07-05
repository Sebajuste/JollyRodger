extends Spatial


onready var cannon := $Cannon
onready var search_await_timer : Timer = $SearchAwaitTimer

onready var capturable := $Capturable


var ships := []

var target_ref := weakref(null)
var ready_to_target := true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target = target_ref.get_ref()
	if target == null and ready_to_target and not ships.empty():
		var t = get_nearest_target()
		if t != null:
			target = t
			search_await_timer.start()
			ready_to_target = false
	
	if target and cannon.fire_ready:
		
		cannon.fire(target.global_transform.origin, target.linear_velocity)
		


func _physics_process(delta):
	var target = target_ref.get_ref()
	if target:
		cannon.look_at(
			target.global_transform.origin,
			Vector3.UP
		)


func get_nearest_target() -> Spatial:
	
	var near_target = null
	var near_distance_squared = null
	
	for ship in ships:
		
		if ship.flag.type != capturable.faction and ship.alive:
			
			var distance_squared := self.global_transform.origin.distance_squared_to(ship.global_transform.origin)
			
			if near_target == null or near_distance_squared > distance_squared:
				near_target = ship
				near_distance_squared = distance_squared
	
	return near_target


func _on_DetectionArea_body_entered(body):
	if body.is_in_group("ship"):
		ships.append(body)


func _on_DetectionArea_body_exited(body):
	if body.is_in_group("ship"):
		var index = ships.find(body)
		if index != -1:
			ships.remove(index)


func _on_SearchAwaitTimer_timeout():
	
	ready_to_target = true
	

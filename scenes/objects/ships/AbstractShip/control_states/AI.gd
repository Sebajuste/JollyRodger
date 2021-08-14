extends ShipState


onready var ai_state := $StateSM


var path : Path


# Called when the node enters the scene tree for the first time.
func _ready():
	
	path = null
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func attack_target(target):
	if Network.enabled and not is_network_master():
		return
	ai_state.transition_to("AvoidObstacle/Combat", {
		"target_object": target
	})
	


func move_to_position(position : Vector3):
	if Network.enabled and not is_network_master():
		return
	path = null
	ai_state.transition_to("AvoidObstacle/MoveToPosition", {
		"move_position": position
	})


func follow_path(_path : Path, reset := true):
	if Network.enabled and not is_network_master():
		return
	path = _path
	ai_state.transition_to("AvoidObstacle/FollowPath", {
		"curve": path.curve,
		"reset": reset
	})


func stop_move():
	if Network.enabled and not is_network_master():
		return
	path = null
	ai_state.transition_to("AvoidObstacle/Idle")


func enter(_msg : Dictionary = {}):
	
	var shape = ship.detection_area.get_node("CollisionShape")
	shape.disabled = false
	$StateSM.enable = true
	
	var _r := ship.detection_area.connect("ennemy_entered", self, "_on_ennemy_entered")
	
	print("[%s] AI enabled" % ship.name)
	pass


func exit():
	
	var shape = ship.detection_area.get_node("CollisionShape")
	shape.disabled = true
	$StateSM.enable = false
	
	ship.detection_area.disconnect("ennemy_entered", self, "_on_ennemy_entered")
	
	print("[%s] AI disabled" % ship.name)
	


func _on_ennemy_entered(_ship : AbstractShip):
	
	ai_state.transition_to("AvoidObstacle/Combat")
	


func _on_DamageStats_damage_taken(_damage, source_path):
	var source := get_node(source_path)
	if source and source.flag.faction != ship.flag.faction:
		attack_target(source)


func _on_StateSM_transitioned(state_path, _msg):
	if state_path == "AvoidObstacle/Idle":
		if path:
			follow_path(path, false)

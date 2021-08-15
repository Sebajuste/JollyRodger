extends Spatial


onready var ai_ship := $SwedishRoyalYachtAmadis
#onready var ennemy_ship = $SwedishRoyalYachtAmadis2


onready var ship_obstacle := $SwedishHemmemaStrybjorn



var patrol_points : PoolVector3Array
var patrol_index := 0

var patrol_position_distance := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	patrol_points = $Path.curve.get_baked_points()
	
	#DebugOverlay.vector.add_vector(ai_ship, "", 1.0, 4.0)
	
	var ai_state = ai_ship.get_node("ControlSM/Control/AI")
	
	
	DebugOverlay.vector.add_vector(ai_ship, "linear_velocity", 1.0, 2.0, Color.blue)
	
	DebugOverlay.vector.add_vector(ai_ship,  "ControlSM/Control/AI/StateSM/AvoidObstacle/chosen_direction", 20.0, 4.0, Color.orange)
	DebugOverlay.stats.add_property(ai_ship, "ControlSM/Control/AI/StateSM/AvoidObstacle/chosen_direction")
	
	#DebugOverlay.vector.add_vector(ai_ship, "ControlSM/Control/AI/StateSM/AvoidObstacle/MoveToPosition/path_direction", 5.0, 4.0, Color.greenyellow)
	
	
	DebugOverlay.stats.add_property(ai_ship, "sail_position")
	DebugOverlay.stats.add_property(ai_ship, "rudder_position")
	DebugOverlay.stats.add_property(ai_ship, "speed")
	DebugOverlay.stats.add_property(ai_state, "path_position")
	DebugOverlay.stats.add_property(self, "patrol_position_distance")
	
	
	
	for i in range(ai_state.get_node("StateSM/AvoidObstacle").NUM_RAYS):
		
		DebugOverlay.vector.add_vector(ai_ship, "ControlSM/Control/AI/StateSM/AvoidObstacle/rays:%d" % i, 40.0, 2.0, Color.green)
		DebugOverlay.vector.add_vector(ai_ship, "ControlSM/Control/AI/StateSM/AvoidObstacle/danger_rays:%d" % i, 40.0, 2.0, Color.red)
		#DebugOverlay.stats.add_property(ai_state, "ray_directions:%d" % i)
	
	#DebugOverlay.vector.add_vector(ai_ship, "ControlSM/Control/AI/rays:0", 30.0, 2.0, Color.purple)
	#DebugOverlay.vector.add_vector(ai_ship, "ControlSM/Control/AI/rays:1", 30.0, 2.0, Color.pink)
	#DebugOverlay.vector.add_vector(ai_ship, "ControlSM/Control/AI/rays:2", 30.0, 2.0, Color.magenta)
	
	#
	#
	#
	
	DebugOverlay.vector.add_vector(ship_obstacle, "linear_velocity", 1.0, 2.0, Color.blue)
	DebugOverlay.stats.add_property(ship_obstacle, "sail_position")
	DebugOverlay.stats.add_property(ship_obstacle, "rudder_position")
	
	
	#var target := patrol_points[patrol_index]
	#ai_state.path_position = target
	
	ai_state.follow_path($Path)
	#ennemy_ship.get_node("ControlSM/Control/AI").follow_path($Path)
	
	
	#
	# Add Equipment
	#
	var cannon := GameTable.get_item(100001)
	
	for _i in range(4):
		ai_ship.equipment.add_item_in_free_slot({
				"item_id": cannon.id,
				"quantity": 1,
				"attributes": cannon.attributes
			}
		)
		
		$Player.equipment.add_item_in_free_slot({
				"item_id": cannon.id,
				"quantity": 1,
				"attributes": cannon.attributes
			}
		)
		
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_SpawnZone_spawn_object(object):
	
	object.faction = "GB"
	object.control_mode = "AI"
	object.control_sm.get_node("Control/AI").follow_path($Path)
	
	var cannon := GameTable.get_item(100001)
	for _i in range(4):
		object.equipment.add_item_in_free_slot({
				"item_id": cannon.id,
				"quantity": 1,
				"attributes": cannon.attributes
			}
		)
	

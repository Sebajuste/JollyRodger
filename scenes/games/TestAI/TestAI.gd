extends Spatial


onready var ai_ship := $SwedishRoyalYachtAmadis

onready var ship_obstacle := $SwedishHemmemaStrybjorn


# Called when the node enters the scene tree for the first time.
func _ready():
	
	#DebugOverlay.vector.add_vector(ai_ship, "", 1.0, 4.0)
	
	var ai_state = ai_ship.get_node("ControlSM/Control/AI")
	
	
	DebugOverlay.vector.add_vector(ai_ship, "linear_velocity", 1.0, 2.0, Color.blue)
	
	DebugOverlay.vector.add_vector(ai_ship, "ControlSM/Control/AI/chosen_direction", 20.0, 4.0, Color.orange)
	#DebugOverlay.vector.add_vector(ai_ship, "ControlSM/Control/AI/path_position", 1.0, 2.0, Color.yellow)
	DebugOverlay.vector.add_vector(ai_ship, "ControlSM/Control/AI/path_direction", 5.0, 4.0, Color.greenyellow)
	
	
	DebugOverlay.stats.add_property(ai_ship, "sail_position")
	DebugOverlay.stats.add_property(ai_ship, "rudder_position")
	DebugOverlay.stats.add_property(ai_state, "path_position")
	DebugOverlay.stats.add_property(ai_ship, "speed")
	
	
	
	for i in range(ai_state.num_rays):
		
		DebugOverlay.vector.add_vector(ai_ship, "ControlSM/Control/AI/rays:%d" % i, 40.0, 2.0, Color.green)
		DebugOverlay.vector.add_vector(ai_ship, "ControlSM/Control/AI/danger_rays:%d" % i, 40.0, 2.0, Color.red)
		#DebugOverlay.stats.add_property(ai_state, "ray_directions:%d" % i)
	
	DebugOverlay.vector.add_vector(ai_ship, "ControlSM/Control/AI/rays:0", 30.0, 2.0, Color.purple)
	DebugOverlay.vector.add_vector(ai_ship, "ControlSM/Control/AI/rays:1", 30.0, 2.0, Color.pink)
	DebugOverlay.vector.add_vector(ai_ship, "ControlSM/Control/AI/rays:2", 30.0, 2.0, Color.magenta)
	
	#
	#
	#
	
	DebugOverlay.vector.add_vector(ship_obstacle, "linear_velocity", 1.0, 2.0, Color.blue)
	DebugOverlay.stats.add_property(ship_obstacle, "sail_position")
	DebugOverlay.stats.add_property(ship_obstacle, "rudder_position")
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

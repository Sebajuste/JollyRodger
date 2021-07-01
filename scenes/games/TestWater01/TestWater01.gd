extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"





# Called when the node enters the scene tree for the first time.
func _ready():
	
	var floaters := get_tree().get_nodes_in_group("water_floater")
	
	for floater in floaters:
		floater.water_manager = water_manager
	
	var floater_managers := get_tree().get_nodes_in_group("water_floater_manager")
	for floater_manager in floater_managers:
		floater_manager.water_manager = water_manager
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

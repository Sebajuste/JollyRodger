extends StaticBody


export var heal_value := 5


onready var detection_area := $DetectionArea
onready var faction_handler := $Capturable




# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_network_master( 1 )
	
	if not Network.enabled or is_network_master():
		
		$RepairTimer.start()
		
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	
#	pass


func _on_RepairTimer_timeout():
	
	if faction_handler.contested:
		print("dock contested")
		return
	
	for damage_stats in get_tree().get_nodes_in_group("damage_stats"):
		for object in detection_area.detected_objects:
			if object.is_a_parent_of(damage_stats):
				
				if object.flag.faction == faction_handler.faction:
					if damage_stats.has_method("heal"):
						damage_stats.heal(heal_value)


func _on_Capturable_contested():
	print("Repair dock contested")
	if not Network.enabled or is_network_master():
		$RepairTimer.stop()


func _on_Capturable_uncontested():
	print("Repair dock cleared")
	if not Network.enabled or is_network_master():
		$RepairTimer.start()

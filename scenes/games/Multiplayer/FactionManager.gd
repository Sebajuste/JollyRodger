class_name FactionManager
extends Node


signal faction_data_updated(faction_data)


var faction_data := {
	"gb_count": 0, 
	"pirate_count": 0
}


# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_network_master( 1 )
	
	Network.connect("properties_created", self, "_on_properties_changed")
	Network.connect("properties_removed", self, "_on_properties_changed")
	Network.connect("property_changed", self, "_on_property_changed")
	
	update_faction_info()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func update_faction_info():
	
	
	faction_data = {
		"gb_count": 0, 
		"pirate_count": 0
	}
	
	for peer_id in Network.player_info:
		var player_info = Network.player_info[peer_id]
		
		if player_info and player_info.has("faction"):
			var faction : String = player_info["faction"]
			
			if faction == "GB":
				faction_data.gb_count += 1
			if faction == "Pirate":
				faction_data.pirate_count += 1
	
	emit_signal("faction_data_updated", faction_data)
	


puppet func rpc_update_faction_data(data):
	faction_data = data
	emit_signal("faction_data_updated", faction_data)


func _on_properties_changed(id, properties):
	
	update_faction_info()
	


func _on_property_changed(id, key, value):
	print("_on_property_changed ", id, ", ", key, ", ", value)
	if key == "faction":
		update_faction_info()
	

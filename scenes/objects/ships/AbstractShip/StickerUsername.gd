extends Label


export var player_username := true setget set_player_username


# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_player_username(player_username)
	


func set_player_username(value):
	
	player_username = value
	if player_username:
		var _r := Network.connect("property_changed", self, "_property_changed")
		var peer_id := get_network_master()
		var username = Network.get_property( peer_id, "username")
		if username:
			self.text = username
	else:
		Network.disconnect("property_changed", self, "_property_changed")
	


func _property_changed(id, key, value):
	if id == get_network_master() and key == "username":
		self.text = value
	

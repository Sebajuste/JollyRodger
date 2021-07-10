extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	Network.connect("property_changed", self, "_property_changed")
	
	# var peer_id = $"../../../".name
	
	var peer_id := get_network_master()
	
	var username = Network.get_property( peer_id, "username")
	if username:
		self.text = username
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var peer_id := get_network_master()
	var username = Network.get_property( peer_id, "username")
	if username:
		self.text = username
	
	pass



func _property_changed(id, key, value):
	print("_property_changed ", id, ", ", key, ", ", value)
	var peer_id = $"../../../".name
	if str(id) == peer_id and key == "username":
		self.text = value
	

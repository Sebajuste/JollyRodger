extends Area

const FACTION_NULL := ""


signal faction_changed(new_faction, old_faction)


# export var capture_repair := true
export(String, "", "GB", "Pirate") var faction := FACTION_NULL setget set_faction

onready var sticker_2d := $Sticker3D/Control
onready var capture_status := $Sticker3D/Control/CaptureStatus




var ship_list := []
var capturing := false
var contested := false


# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_network_master( 1 )
	_update_faction()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_faction_capture() -> Dictionary:
	
	var search_faction = FACTION_NULL
	
	var faction_info := {
		"faction": self.faction,
		"current_capturing_faction": FACTION_NULL,
		"capturing": false,
		"contested": false
	}
	
	for ship in ship_list:
		
		if search_faction == FACTION_NULL:
			search_faction = ship.flag.faction
		
		print("search_faction: ", search_faction, ", ship.flag.faction: ", ship.flag.faction)
		
		if search_faction != ship.flag.faction:
			faction_info.contested = true
			faction_info.capturing = false
			#faction_info.current_capturing_faction = self.faction
			
			#return self.faction
			return faction_info
	
	#return search_faction if search_faction != FACTION_NULL else self.faction
	
	if search_faction != FACTION_NULL:
		faction_info.contested = true if search_faction != self.faction else false
		faction_info.capturing = true if search_faction != self.faction else false
		if search_faction != self.faction:
			faction_info.current_capturing_faction = search_faction
	else:
		faction_info.contested = false
		faction_info.capturing = false
		#faction_info.current_capturing_faction = self.faction
	
	return faction_info


func _update_capture():
	print("_update_capture, current : ", self.faction)
	var faction_info := get_faction_capture()
	print("faction_info : ", faction_info )
	
	if Network.enabled and is_network_master():
		rpc("rpc_capture_status", faction_info)
	rpc_capture_status(faction_info)
	
	"""
	if faction_capture != FACTION_NULL and faction != faction_capture and not capturing:
		
		print("Capturing")
		if Network.enabled and is_network_master():
			rpc("rpc_capture_status", self.faction, true)
		rpc_capture_status(self.faction, true)
	elif faction == faction_capture and capturing:
		
		print("No capture")
		if Network.enabled and is_network_master():
			rpc("rpc_capture_status", self.faction, false)
		rpc_capture_status(self.faction, false)
	"""


func _update_faction():
	for node in get_tree().get_nodes_in_group("faction_capturable"):
		if self.is_a_parent_of(node):
			node.faction = faction
			node.contested = contested
	
	"""
	if capture_repair:
		for node in get_tree().get_nodes_in_group("damage_stats"):
			if self.is_a_parent_of(node):
				node.health = node.max_health
	"""
	


master func rpc_request_faction():
	
	var peer_id := get_tree().get_rpc_sender_id()
	var capture_time := -1.0
	
	if capturing:
		capture_time = $CaptureTimer.wait_time - $CaptureTimer.time_left
	
	var faction_info := {
		"faction": self.faction,
		"capturing": self.capturing,
		"contested": self.contested
	}
	
	rpc_id(peer_id, "rpc_capture_status", faction_info, capture_time)
	


puppet func rpc_capture_status(capture_info : Dictionary, capture_time := -1.0):
	
	print("rpc_capture_status : ", capture_info)
	
	var old_faction = self.faction
	
	self.faction = capture_info.faction
	self.capturing = capture_info.capturing
	self.contested = capture_info.contested
	
	if capturing:
		capture_status.visible = true
		capture_status.set_process(true)
		$CaptureTimer.start(capture_time)
	else:
		capture_status.visible = false
		capture_status.set_process(false)
		$CaptureTimer.stop()
	
	_update_faction()
	
	if old_faction != faction:
		
		emit_signal("faction_changed", self.faction, old_faction)
		


func set_faction(value):
	faction = value
	if get_tree():
		_update_faction()


func _on_CapureZone_body_entered(body : Spatial):
	if Network.enabled and not is_network_master():
		return
	if body.is_in_group("ship"):
		ship_list.append(body)
		_update_capture()


func _on_CapureZone_body_exited(body : Spatial):
	if Network.enabled and not is_network_master():
		return
	var index := ship_list.find(body)
	if index != -1:
		ship_list.remove(index)
		_update_capture()


func _on_CaptureTimer_timeout():
	
	if Network.enabled and not is_network_master():
		return
	
	var capture_info := get_faction_capture()
	if capture_info.current_capturing_faction == FACTION_NULL:
		print("no new faction ?")
		return
	
	print("Capture timeout : ", capture_info)
	
	if capture_info.capturing:
		capture_info.faction = capture_info.current_capturing_faction
		capture_info.capturing = false
		capture_info.contested = false
	
	if Network.enabled and is_network_master():
		rpc("rpc_capture_status", capture_info)
	rpc_capture_status(capture_info)


func _on_CaptureZone_tree_entered():
	if Network.enabled and not is_network_master():
		rpc("rpc_request_faction")

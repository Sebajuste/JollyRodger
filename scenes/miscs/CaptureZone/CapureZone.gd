extends Area

const FACTION_NULL := ""


signal faction_changed(new_faction, old_faction)


# export var capture_repair := true
export(String, "", "GB", "Pirate") var faction := FACTION_NULL setget set_faction
export var capture_delay := 60 setget set_capture_delay


onready var sticker_2d := $Sticker3D/Control
onready var capture_status := $Sticker3D/Control/CaptureStatus
onready var capture_timer := $CaptureTimer



var ship_list := []
var capturing := false
var contested := false


# Called when the node enters the scene tree for the first time.
func _ready():
	set_capture_delay(capture_delay)
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
	
	#for ship_ref in ship_list:
	for index in range(ship_list.size()-1, -1, -1):
		var ship_ref : WeakRef = ship_list[index]
		var ship = ship_ref.get_ref()
		
		if not ship:
			ship_list.remove(index)
			continue
		
		if search_faction == FACTION_NULL:
			search_faction = ship.flag.faction
		
		if search_faction != ship.flag.faction:
			faction_info.contested = true
			faction_info.capturing = false
			
			return faction_info
	
	if search_faction != FACTION_NULL:
		faction_info.contested = true if search_faction != self.faction else false
		faction_info.capturing = true if search_faction != self.faction else false
		if search_faction != self.faction:
			faction_info.current_capturing_faction = search_faction
	else:
		faction_info.contested = false
		faction_info.capturing = false
	
	return faction_info


func _update_capture():
	var faction_info := get_faction_capture()
	if Network.enabled and is_network_master():
		rpc("rpc_capture_status", faction_info)
	rpc_capture_status(faction_info)


func _update_faction():
	for node in get_tree().get_nodes_in_group("faction_capturable"):
		if self.is_a_parent_of(node):
			node.faction = faction
			node.contested = contested


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
	if is_inside_tree():
		_update_faction()


func set_capture_delay(value):
	capture_delay = int(max(0, value))
	if capture_timer:
		capture_timer.wait_time = capture_delay


func find_ship_ref(ship : AbstractShip) -> WeakRef:
	for ship_ref in ship_list:
		if ship_ref.get_ref() == ship:
			return ship_ref
	return null


func _on_CapureZone_body_entered(body : Spatial):
	if Network.enabled and not is_network_master():
		return
	if body.is_in_group("ship") and body.alive:
		ship_list.append(weakref(body))
		var _r := body.connect("destroyed", self, "_on_ship_destroyed", [body])
		_update_capture()


func _on_CapureZone_body_exited(body : Spatial):
	if Network.enabled and not is_network_master():
		return
	
	var ship_ref := find_ship_ref(body)
	if ship_ref:
		ship_list.erase(ship_ref)
		body.disconnect("destroyed", self, "_on_ship_destroyed")
		_update_capture()


func _on_ship_destroyed(ship):
	if ship and not ship.alive:
		var ship_ref := find_ship_ref(ship)
		if ship_ref:
			ship_list.erase(ship_ref)
			ship.disconnect("destroyed", self, "_on_ship_destroyed")
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

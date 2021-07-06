extends Area

const FACTION_NULL := ""


signal faction_changed(new_faction, old_faction)


onready var sticker_2d := $Sticker3D/Control
onready var capture_status := $Sticker3D/Control/CaptureStatus


var faction := FACTION_NULL setget set_faction

var ship_list := []
var capturing := false


# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_network_master( 1 )
	_update_faction()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_faction_capture() -> String:
	
	var search_faction = FACTION_NULL
	
	for ship in ship_list:
		
		if search_faction == FACTION_NULL:
			search_faction = ship.flag.faction
		
		print("search_faction: ", search_faction, ", ship.flag.faction: ", ship.flag.faction)
		
		if search_faction != ship.flag.faction:
			return self.faction
	
	return search_faction if search_faction != FACTION_NULL else self.faction


func _update_capture():
	print("_update_capture, current : ", self.faction)
	var faction_capture := get_faction_capture()
	print("faction_capture : ", faction_capture )
	if faction_capture != FACTION_NULL and faction != faction_capture and not capturing:
		#capturing = true
		#capture_status.set_process(true)
		#$CaptureTimer.start()
		print("Capturing")
		if Network.enabled and is_network_master():
			rpc("rpc_capture_status", true, self.faction)
		else:
			rpc_capture_status(true, self.faction)
	elif faction == faction_capture and capturing:
		
		#capturing = false
		#capture_status.set_process(false)
		#$CaptureTimer.stop()
		print("No capture")
		if Network.enabled and is_network_master():
			rpc("rpc_capture_status", false, self.faction)
		else:
			rpc_capture_status(false, self.faction)


func _update_faction():
	for node in get_tree().get_nodes_in_group("faction_capturable"):
		if self.is_a_parent_of(node):
			node.faction = faction
	
	for node in get_tree().get_nodes_in_group("damage_stats"):
		if self.is_a_parent_of(node):
			node.health = node.max_health
	
	


puppet func rpc_capture_status(capturing : bool, faction : String):
	
	print("rpc_capture_status")
	
	var old_faction = self.faction
	
	self.faction = faction
	self.capturing = capturing
	
	if capturing:
		capture_status.visible = true
		capture_status.set_process(true)
		$CaptureTimer.start()
	else:
		capture_status.visible = false
		capture_status.set_process(false)
		$CaptureTimer.stop()
	
	_update_faction()
	
	if old_faction != faction:
		
		emit_signal("faction_changed", self.faction, old_faction)
		
	


func set_faction(value):
	faction = value
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
	var new_faction = get_faction_capture()
	if not new_faction:
		print("no new faction ?")
		return
	
	#var old_faction := self.faction
	#capturing = false
	#capture_status.set_process(false)
	#$Control.visible = false
	#self.faction = new_faction
	
	
	#_update_faction()
	
	print("New faction : ", new_faction)
	
	if Network.enabled and is_network_master():
		rpc("rpc_capture_status", false, self.faction)
	else:
		rpc_capture_status(false, new_faction)

extends Area

const FACTION_NULL := ""


signal faction_changed(new_faction, old_faction)


onready var sticker := $Sticker3D
onready var capture_status := $Sticker3D/Control/CaptureStatus


var faction := FACTION_NULL

var ship_list := []
var capturing := false


# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_network_master( 1 )
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_faction_capture() -> String:
	
	var search_faction = null
	
	for ship in ship_list:
		
		if search_faction == null:
			search_faction = ship.flag.type
		
		print("search_faction: ", search_faction, ", ship.flag.type: ", ship.flag.type)
		
		if search_faction != ship.flag.type:
			return self.faction
	
	return search_faction


func _update_capture():
	print("_update_capture")
	var faction_capture := get_faction_capture()
	print("faction_capture : ", faction_capture )
	if faction_capture != FACTION_NULL and faction != faction_capture and not capturing:
		capturing = true
		sticker.visible = true
		capture_status.set_process(true)
		$CaptureTimer.start()
		print("Capturing")
		if Network.enabled and is_network_master():
			rpc("rpc_capture_status", true, self.faction)
	elif faction == faction_capture and capturing:
		sticker.visible = false
		capturing = false
		capture_status.set_process(false)
		$CaptureTimer.stop()
		if Network.enabled and is_network_master():
			rpc("rpc_capture_status", false, self.faction)


func _update_faction():
	for node in get_tree().get_nodes_in_group("capturable"):
		if self.is_a_parent_of(node):
			node.faction = faction


puppet func rpc_capture_status(capturing : bool, faction : String):
	
	self.faction = faction
	
	if not self.capturing and capturing:
		capturing = true
		sticker.visible = true
		capture_status.set_process(true)
		$CaptureTimer.start()
	elif self.capturing and not capturing:
		sticker.visible = false
		capturing = false
		capture_status.set_process(false)
		$CaptureTimer.stop()
	
	_update_faction()
	


func _on_CapureZone_body_entered(body : Spatial):
	
	if Network.enabled and not is_network_master():
		return
	
	print("_on_CapureZone_body_entered")
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
	
	var old_faction := self.faction
	capturing = false
	capture_status.set_process(false)
	sticker.visible = false
	self.faction = new_faction
	emit_signal("faction_changed", self.faction, old_faction)
	
	_update_faction()
	
	print("New faction : ", new_faction)
	
	if Network.enabled and is_network_master():
		
		rpc("rpc_capture_status", false, self.faction)
		

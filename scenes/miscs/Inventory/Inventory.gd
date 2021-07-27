class_name Inventory
extends Node


signal inventory_updated(items)


export var max_slot := 24

var items : Dictionary = {}



# Called when the node enters the scene tree for the first time.
func _ready():
	
	if items.empty():
		items = Dictionary()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func has_item(slot_id : int):
	
	return items.has(slot_id)
	


func get_item(slot_id : int) -> Dictionary:
	
	return items[slot_id]
	


func get_quantity(slot_id : int) -> int:
	if items.has(slot_id):
		return items[slot_id].quantity
	return 0


func add_item(slot_id : int, item : Dictionary):
	if Network.enabled:
		rpc("rpc_add_item", slot_id, item)
	else:
		rpc_add_item(slot_id, item)


func change_quantity(slot_id : int, quantity : int):
	if Network.enabled:
		rpc("rpc_change_quantity", slot_id, quantity)
	else:
		rpc_change_quantity(slot_id, quantity)


func remove_item(slot_id : int):
	if Network.enabled:
		rpc("rpc_remove_item", slot_id)
	else:
		rpc_remove_item(slot_id)


mastersync func rpc_add_item(slot_id : int, item : Dictionary):
	
	if items.has(slot_id):
		if items[slot_id].item_id == item.item_id:
			change_quantity(slot_id, items[slot_id].quantity + item.quantity)
			emit_signal("inventory_updated", items)
	else:
		items[slot_id] = item
		emit_signal("inventory_updated", items)
		print("[%s] Add item [%d]" % [name, slot_id], item)


mastersync func rpc_change_quantity(slot_id : int, quantity : int):
	if items.has(slot_id):
		items[slot_id].quantity = quantity
		emit_signal("inventory_updated", items)
		print("[%s] Change quantity [%d] : " % [name, slot_id], quantity)


mastersync func rpc_remove_item(slot_id : int):
	items.erase(slot_id)
	emit_signal("inventory_updated", items)
	print("[%s] Remove item [%d]" % [name, slot_id])


master func rpc_request_inventory():
	var peer_id := get_tree().get_rpc_sender_id()
	rpc_id(peer_id, "rpc_sync_inventory", items)


puppet func rpc_sync_inventory(value : Dictionary):
	
	items = value
	emit_signal("inventory_updated", items)
	


func _on_tree_entered():
	if Network.enabled and not is_network_master():
		rpc("rpc_request_inventory")

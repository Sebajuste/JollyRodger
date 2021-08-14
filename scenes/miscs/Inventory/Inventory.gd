class_name Inventory
extends Node


signal inventory_updated(items)

signal item_added(slot_id, item)
signal item_removed(slot_id, item)
signal item_quantity_changed(slot_id, item, old_quantity)


export var max_slot := 24

var items : Dictionary = {}



# Called when the node enters the scene tree for the first time.
func _ready():
	
	if items.empty():
		items = Dictionary()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func has_items() -> bool:
	
	return not items.empty()
	


func has_item(slot_id : int) -> bool:
	
	return items.has(slot_id)
	


func get_same_free_slot(item : GameItem) -> int:
	if items.size() < max_slot:
		for slot_id in range(max_slot):
			if items.has( slot_id ) and items[slot_id].item_id == item.id:
				return slot_id
	return -1


func get_free_slot() -> int:
	if items.size() < max_slot:
		for slot_id in range(max_slot):
			if not items.has( slot_id ):
				return slot_id
	return -1


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


func add_item_in_free_slot(item_description : Dictionary):
	
	var slot_id := -1
	
	var item := GameTable.get_item(item_description.item_id)
	if item.max_stack > 1:
		slot_id = get_same_free_slot(item)
	
	if slot_id == -1:
		slot_id = get_free_slot()
	
	if slot_id != -1:
		add_item(slot_id, item_description)


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
			emit_signal("item_added", slot_id, item)
	else:
		items[slot_id] = item
		emit_signal("inventory_updated", items)
		emit_signal("item_added", slot_id, item)
		print("[%s] Add item [%d]" % [name, slot_id], item)


mastersync func rpc_change_quantity(slot_id : int, quantity : int):
	if items.has(slot_id):
		var old_quantity : int = items[slot_id].quantity
		items[slot_id].quantity = quantity
		emit_signal("inventory_updated", items)
		emit_signal("item_quantity_changed", slot_id, items[slot_id], old_quantity)
		print("[%s] Change quantity [%d] : " % [name, slot_id], quantity)


mastersync func rpc_remove_item(slot_id : int):
	if items.has(slot_id):
		var item = items[slot_id]
		var _r := items.erase(slot_id)
		emit_signal("inventory_updated", items)
		emit_signal("item_removed", slot_id, item)
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

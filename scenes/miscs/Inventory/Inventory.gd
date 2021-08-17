class_name Inventory
extends Node


signal inventory_updated(items)

signal item_added(slot_id, item)
signal item_removed(slot_id, item)
signal item_quantity_changed(slot_id, item, old_quantity)


export var max_slot := 24

var items : Dictionary = {}


var peers := []


# Called when the node enters the scene tree for the first time.
func _ready():
	
	if items.empty():
		items = Dictionary()
	
	if Network.enabled and not is_network_master():
		rpc("rpc_request_inventory")
	
	var _r = get_tree().connect("network_peer_disconnected", self, "_player_disconnected")


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


func subscribe():
	if Network.enabled:
		if not is_network_master():
			rpc("rpc_subscribe")
	pass


func unsubsribe():
	if Network.enabled:
		if not is_network_master():
			rpc("rpc_unsubscribe")
	pass


func sync_inventory():
	if Network.enabled:
		if is_network_master():
			for peer_id in peers:
				rpc_id(peer_id, "rpc_sync_inventory", items)
		else:
			push_warning("Puppet cannot sync inventory")


master func rpc_subscribe():
	var peer_id = get_tree().get_rpc_sender_id()
	if not peers.has(peer_id):
		peers.append(peer_id)
		rpc_id(peer_id, "rpc_sync_inventory", items)


master func rpc_unsubsribe():
	var peer_id = get_tree().get_rpc_sender_id()
	peers.erase(peer_id)


mastersync func rpc_add_item(slot_id : int, item : Dictionary):
	
	if items.has(slot_id):
		if items[slot_id].item_id == item.item_id:
			change_quantity(slot_id, items[slot_id].quantity + item.quantity)
			emit_signal("inventory_updated", items)
			emit_signal("item_added", slot_id, item)
			sync_inventory()
		else:
			push_warning("Cannot add item in inventory slot")
	else:
		items[slot_id] = item
		emit_signal("inventory_updated", items)
		emit_signal("item_added", slot_id, item)
		sync_inventory()
		print("[%s] Add item [%d]" % [name, slot_id], item)


mastersync func rpc_change_quantity(slot_id : int, quantity : int):
	if items.has(slot_id):
		var old_quantity : int = items[slot_id].quantity
		items[slot_id].quantity = quantity
		emit_signal("inventory_updated", items)
		emit_signal("item_quantity_changed", slot_id, items[slot_id], old_quantity)
		sync_inventory()
		print("[%s] Change quantity [%d] : " % [name, slot_id], quantity)
	else:
		push_warning("Cannot change inventory slot quantity")


mastersync func rpc_remove_item(slot_id : int):
	if items.has(slot_id):
		var item = items[slot_id]
		var _r := items.erase(slot_id)
		emit_signal("inventory_updated", items)
		emit_signal("item_removed", slot_id, item)
		sync_inventory()
		print("[%s] Remove item [%d]" % [name, slot_id])
	else:
		push_warning("Cannot remove item in inventory slot")


master func rpc_request_inventory():
	var peer_id := get_tree().get_rpc_sender_id()
	rpc_id(peer_id, "rpc_sync_inventory", items)
	print("call rpc_request_inventory on ", peer_id, ", master is :", get_network_master())


puppet func rpc_sync_inventory(value : Dictionary):
	items = value
	emit_signal("inventory_updated", items)


func _player_disconnected(peer_id : int):
	if peers.has(peer_id):
		peers.erase(peer_id)
	

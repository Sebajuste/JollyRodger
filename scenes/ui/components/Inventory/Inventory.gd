class_name GUIInventory
extends GUIAbstractInventory


onready var grid_container := $GridContainer



#var holding_item : Control
#var last_slot_used : InventoryItemSlot


# Called when the node enters the scene tree for the first time.
func _ready():
	
	for slot in grid_container.get_children():
		
		slot.connect("slot_action", self, "_on_slot_action", [slot])
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func update_inventory():
	"""
	# Clear
	for child in grid_container.get_children():
		child.queue_free()
	
	for slot_id in range(inventory.max_slot):
		var slot = INVENTORY_SLOT_SCENE.instance()
		slot.slot_id = slot_id
		grid_container.add_child(slot)
	"""
	
	.update_inventory()
	


func get_container() -> Node:
	
	return grid_container
	


func get_first_empty_slot(item_id : int = -1) -> InventoryItemSlot:
	# Search first same items
	if item_id > 0:
		for slot in grid_container.get_children():
			if slot.has_item() and slot.item_handler.item.id == item_id and slot.item_handler.item.max_stack > 1:
				return slot
	
	# Search empty slot
	for slot in grid_container.get_children():
		if not slot.has_item():
			return slot
	return null


func _on_slot_action(type, slot):
	
	emit_signal("slot_action", type, slot)
	
	pass

class_name InventoryItemSlot
extends AbstractItemSlot



var slot_id : int = -1

var gui_inventory



func _ready():
	
	gui_inventory = _get_parent_inventory( get_parent() )
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func put(new_item : ItemHandler, amount : int = -1) -> bool:
	
	var result := .put(new_item, amount)
	
	if amount == -1:
		amount = new_item.quantity
	
	if result:
		gui_inventory.inventory.add_item(slot_id, {
			"item_id": new_item.item.id,
			"quantity": amount,
			"attributes": new_item.attributes
		})
	return result


func pick(amount : int = -1) -> ItemHandler:
	
	var item = .pick(amount)
	
	if amount == -1 or amount == gui_inventory.inventory.items[slot_id].quantity:
		gui_inventory.inventory.remove_item(slot_id)
	else:
		gui_inventory.inventory.change_quantity(slot_id, gui_inventory.inventory.get_quantity(slot_id) - amount)
	
	return item


func _get_parent_inventory(n : Node) -> Node:
	if not n:
		return null
	if n.is_in_group("gui_inventory"):
		return n
	return _get_parent_inventory(n.get_parent())

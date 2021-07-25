class_name GUIAbstractInventory
extends Control


signal slot_action(type, slot)


var INVENTORY_SLOT_SCENE = preload("slots/InventoryItemSlot/InventoryItemSlot.tscn")
var ITEM_HANDLER_SCENE = preload("ItemHandler/ItemHandler.tscn")


export(NodePath) var inventory_path
export var slot_count := 24


var inventory : Inventory 



# Called when the node enters the scene tree for the first time.
func _ready():
	
	if not inventory and inventory_path:
		inventory = get_node(inventory_path)
	
	if inventory:
		update_inventory()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func update_inventory():
	
	var container := get_container()
	
	if not container:
		return
	
	# Clear
	for slot_id in range(container.get_child_count()):
		var slot = container.get_child(slot_id)
		slot.slot_id = slot_id
	
	# Add items
	for slot_id in inventory.items:
		
		var item_info : Dictionary = inventory.items[slot_id]
		
		var item := GameTable.get_item(item_info.item_id)
		
		var gui_item = ITEM_HANDLER_SCENE.instance()
		gui_item.item = item
		gui_item.quantity = item_info.quantity
		
		var slot = container.get_child(slot_id)
		slot.slot_id = slot_id
		slot.item_handler = gui_item


func get_container() -> Node:
	
	return null
	

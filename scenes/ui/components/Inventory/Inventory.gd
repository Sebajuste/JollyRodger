class_name GUIInventory
extends Control


var ITEM_HANDLER_SCENE = preload("ItemHandler/ItemHandler.tscn")


export(NodePath) var inventory_path
export var slot_count := 24


onready var grid_container := $GridContainer


var inventory : Inventory setget set_inventory


#var holding_item : Control
#var last_slot_used : InventoryItemSlot


# Called when the node enters the scene tree for the first time.
func _ready():
	
	if not inventory and inventory_path:
		inventory = get_node(inventory_path)
	
	
	if inventory:
		update_inventory()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func update_inventory():
	
	var slot_index := 0
	for item_id in inventory.items:
		
		var quantity : int = inventory.items[item_id]
		
		var item := GameTable.get_item(item_id)
		
		var gui_item = ITEM_HANDLER_SCENE.instance()
		gui_item.item = item
		gui_item.quantity = quantity
		
		var slot = $GridContainer.get_child(slot_index)
		
		slot.put(gui_item)
		
		slot_index += 1
	
	pass


func set_inventory(value):
	inventory = value
	if inventory:
		update_inventory()

class_name GUIInventory
extends GUIAbstractInventory


onready var grid_container := $GridContainer



#var holding_item : Control
#var last_slot_used : InventoryItemSlot


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


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
	

class_name GUIEquipment
extends GUIAbstractInventory


onready var ship_draw := $ShipDraw


# Called when the node enters the scene tree for the first time.
func _ready():
	
	for slot in ship_draw.get_children():
		
		slot.connect("slot_action", self, "_on_slot_action", [slot])
		
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func update_inventory():
	
	.update_inventory()
	


func get_container() -> Node:
	
	return ship_draw
	


func get_same_equipment_slot(item : GameItem) -> InventoryItemSlot:
	for slot in ship_draw.get_children():
		if not slot.has_item() and slot.filter_category == item.category and slot.filter_type == item.type:
			return slot
	return null


func _on_slot_action(type, slot):
	
	emit_signal("slot_action", type, slot)
	
	pass

extends WindowDialog


onready var ship_equipment : GUIEquipement = $MarginContainer/VBoxContainer/Content/HBoxContainer/VBoxContainer/ShipEquipment
onready var ship_inventory : GUIInventory = $MarginContainer/VBoxContainer/Content/HBoxContainer/ShipInventory


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_visibility_changed():
	
	if visible:
		print("ship inventory visible")
		$AnimationPlayer.play("fade_in")
		#if ship_equipment:
		ship_equipment.update_inventory()
		#if ship_inventory:
		ship_inventory.update_inventory()
		


func _on_popup_hide():
	
	queue_free()
	


func _on_ShipEquipment_slot_action(type, slot):
	
	if type == "secondary":
		
		var empty_slot := ship_inventory.get_first_empty_slot(slot.item_handler.item.id)
		
		if empty_slot:
			
			if empty_slot.has_item():
				empty_slot.item_transfer(slot)
			else:
				empty_slot.item_give(slot)
			
		
		print("_on_item_equiped")
	
	pass # Replace with function body.


func _on_ShipInventory_slot_action(type, slot):
	
	if type == "secondary":
		
		var empty_slot := ship_equipment.get_same_equipement_slot(slot.item_handler.item)
		
		if empty_slot:
			
			if empty_slot.has_item():
				empty_slot.item_transfer(slot)
			else:
				empty_slot.item_give(slot)
			
		





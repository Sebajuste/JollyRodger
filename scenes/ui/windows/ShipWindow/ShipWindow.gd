extends WindowDialog


onready var ship_equipment : GUIEquipment = $MarginContainer/VBoxContainer/Content/HBoxContainer/VBoxContainerLeft/ShipEquipment
onready var ship_inventory : GUIInventory = $MarginContainer/VBoxContainer/Content/HBoxContainer/VBoxContainerRight/ShipInventory
onready var trash_item_slot : TrashItemSlot = $MarginContainer/VBoxContainer/Content/HBoxContainer/VBoxContainerRight/HBoxContainer/TrashItemSlot


var ship_ref := weakref(null)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	var ship = ship_ref.get_ref()
	if ship:
		trash_item_slot.owner_ref = weakref(ship)
	
	pass


func _on_visibility_changed():
	if visible:
		$AnimationPlayer.play("fade_in")
		ship_equipment.update_inventory()
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


func _on_ShipInventory_slot_action(type, slot):
	
	if type == "secondary":
		var empty_slot := ship_equipment.get_same_equipment_slot(slot.item_handler.item)
		if empty_slot:
			if empty_slot.has_item():
				empty_slot.item_transfer(slot)
			else:
				empty_slot.item_give(slot)


func _on_CloseButton_pressed():
	
	hide()
	

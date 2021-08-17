extends WindowDialog



onready var label_a := $MarginContainer/HBoxContainer/From/VBoxContainer/Label
onready var label_b := $MarginContainer/HBoxContainer/To/VBoxContainer/Label

onready var gui_inventory_a : GUIInventory = $MarginContainer/HBoxContainer/From/VBoxContainer/Inventory
onready var gui_inventory_b : GUIInventory = $MarginContainer/HBoxContainer/To/VBoxContainer/Inventory


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_name_a(name : String):
	
	label_a.text = name
	


func set_name_b(name : String):
	
	label_b.text = name
	


func set_inventory_a(inventory : Inventory):
	gui_inventory_a.set_inventory( inventory )
	var _r := inventory.connect("tree_exited", self, "_on_close_inventory")


func set_inventory_b(inventory : Inventory):
	gui_inventory_b.set_inventory( inventory )
	var _r := inventory.connect("tree_exited", self, "_on_close_inventory")


func _on_about_to_show():
	
	gui_inventory_a.update_inventory()
	gui_inventory_b.update_inventory()


func _on_visibility_changed():
	if visible:
		_on_about_to_show()
		$AnimationPlayer.play("fade_in")



func item_transfer(from : InventoryItemSlot, to : InventoryItemSlot):
	if to.has_item():
		to.item_transfer(from)
	else:
		to.item_give(from)


func _on_InventoryA_slot_action(_type, slot):
	var empty_slot := gui_inventory_b.get_first_empty_slot(slot.item_handler.item.id)
	if empty_slot:
		item_transfer(slot, empty_slot)


func _on_InventoryB_slot_action(_type, slot):
	var empty_slot := gui_inventory_a.get_first_empty_slot(slot.item_handler.item.id)
	if empty_slot:
		item_transfer(slot, empty_slot)


func _on_close_inventory():
	
	queue_free()
	

extends WindowDialog


onready var gui_inventory_a := $MarginContainer/HBoxContainer/From/VBoxContainer/Inventory
onready var gui_inventory_b := $MarginContainer/HBoxContainer/To/VBoxContainer/Inventory


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_inventory_a(inventory : Inventory):
	gui_inventory_a.inventory = inventory
	gui_inventory_a.update_inventory()


func set_inventory_b(inventory : Inventory):
	gui_inventory_b.inventory = inventory
	gui_inventory_b.update_inventory()

extends SimpleWindow


onready var ship_equipment := $MarginContainer/VBoxContainer/Content/HBoxContainer/VBoxContainer/ShipEquipment
onready var ship_inventory := $MarginContainer/VBoxContainer/Content/HBoxContainer/ShipInventory


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_inventory(inventory : Inventory):
	
	ship_inventory.inventory = inventory
	
	pass

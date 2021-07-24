extends WindowDialog


onready var ship_equipment := $MarginContainer/VBoxContainer/Content/HBoxContainer/VBoxContainer/ShipEquipment
onready var ship_inventory := $MarginContainer/VBoxContainer/Content/HBoxContainer/ShipInventory


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_visibility_changed():
	
	if visible:
		$AnimationPlayer.play("fade_in")
		ship_equipment.update_inventory()
		ship_inventory.update_inventory()
		
	else:
		queue_free()


func _on_popup_hide():
	
	queue_free()
	

extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var inventory : Inventory setget set_inventory



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func update_equipement():
	
	pass


func set_inventory(value):
	inventory = value
	if inventory:
		update_equipement()

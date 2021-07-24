extends GUIAbstractInventory



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_inventory():
	
	.update_inventory()
	


func get_container() -> Node:
	
	return $Ship
	

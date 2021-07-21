class_name InventoryItemSlot
extends AbstractItemSlot



#var inventory



func _ready():
	
	#inventory = _get_parent_inventory( get_parent() )
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

"""
func _get_parent_inventory(n : Node) -> Node:
	if not n:
		return null
	if n.is_in_group("inventory"):
		return n
	return _get_parent_inventory(n.get_parent())
"""

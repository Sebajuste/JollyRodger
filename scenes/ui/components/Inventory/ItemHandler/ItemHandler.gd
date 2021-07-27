class_name ItemHandler
extends Control


signal quantity_changed(quantity)


export(Resource) var item setget set_item
export var quantity : int = 0 setget set_quantity


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func is_item_type(type : String) -> bool:
	
	return true if item.type == type else false
	


func is_item_category(category : String) -> bool:
	
	return true if item.category == category else false
	


func set_item(new_item : GameItem):
	if new_item:
		item = new_item
		$TextureRect.texture = item.icon


func set_quantity(value):
	var old_quantity := quantity
	quantity = max(1, value)
	if old_quantity != quantity:
		emit_signal("quantity_changed", quantity)

class_name AbstractItemSlot
extends Panel


signal item_equiped(item)
signal item_unequiped(item)


export var filter_category := ""
export var filter_type := ""
export var max_quantity := 2 setget set_max_quantity


onready var stack_label = $StackLabel


var item_control : ItemControl


# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_max_quantity( max_quantity )
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_drag_data(_pos):
	
	if has_item():
		
		var preview := TextureRect.new()
		preview.expand = true
		preview.texture = item_control.item.icon
		preview.rect_size = Vector2(48, 48)
		preview.rect_min_size = Vector2(48, 48)
		preview.mouse_filter = MOUSE_FILTER_IGNORE
		
		set_drag_preview(preview)
		
		return self
	
	return false
	


func can_drop_data(_pos, slot):
	if slot.is_in_group("gui_item_slot"):
		return can_equipe(slot.item_control)
	return false


func drop_data(_pos, source_slot):
	
	var item_a : ItemControl = source_slot.pick()
	var item_b
	
	if has_item():
		item_b = pick()
	
	put(item_a)
	
	if item_b:
		source_slot.put(item_b)
	


func has_item() -> bool:
	
	return item_control != null
	


func can_equipe(item : ItemControl) -> bool:
	if filter_type != "" and filter_category != "":
		return true if item.is_item_type(filter_type) and item.is_item_category(filter_category) else false
	elif filter_type != "":
		return item.is_item_type(filter_type)
	elif filter_category != "":
		return item.is_item_category(filter_category)
	return true


func pick() -> ItemControl:
	if item_control:
		var result := item_control
		remove_child( item_control )
		item_control = null
		stack_label.visible = false
		emit_signal("item_unequiped", result)
		result.disconnect("quantity_changed", self, "_on_quantity_changed")
		return result
	return null


func put(new_item : ItemControl) -> bool:
	
	item_control = new_item
	item_control.rect_position = Vector2.ZERO
	
	if item_control.get_parent():
		item_control.get_parent().remove_child(item_control)
	
	add_child(item_control)
	if max_quantity > 1:
		stack_label.visible = true
		stack_label.text = str(new_item.quantity)
		
	
	item_control.connect("quantity_changed", self, "_on_quantity_changed")
	
	emit_signal("item_equiped", item_control)
	
	return true


func set_max_quantity(value):
	
	max_quantity = max(1, value)
	


func _on_quantity_changed(quantity : int):
	
	stack_label.text = str(quantity)
	

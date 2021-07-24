class_name AbstractItemSlot
extends Panel

var TOOLTIP_SCENE = preload("res://scenes/ui/components/Inventory/ItemTooltip/ItemTooltip.tscn")
var ITEM_HANDLER_SCENE = preload("res://scenes/ui/components/Inventory/ItemHandler/ItemHandler.tscn")
var SPLIT_POPUP_SCENE = preload("res://scenes/ui/components/Inventory/ItemSplitPopup/ItemSplitPopup.tscn")

signal item_equiped(item)
signal item_unequiped(item)


export var filter_category := ""
export var filter_type := ""
export var max_quantity := 250 setget set_max_quantity


onready var stack_label = $StackLabel


var item_handler : ItemHandler setget set_item_handler


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
		preview.texture = item_handler.item.icon
		preview.rect_size = Vector2(48, 48)
		preview.rect_min_size = Vector2(48, 48)
		preview.mouse_filter = MOUSE_FILTER_IGNORE
		
		set_drag_preview(preview)
		
		return self
	
	return null
	


func can_drop_data(_pos, slot):
	if slot.is_in_group("gui_item_slot"):
		if can_equipe(slot.item_handler):
			if not has_item(): # if slot empty
				return true
			else: # if sawp item
				if Input.is_action_pressed("secondary"):
					if slot.item_handler.item.id == item_handler.item.id:
						return true
					else:
						return false
			return true
	return false


func drop_data(_pos, source_slot):
	
	if Input.is_action_pressed("secondary"):
		
		var split_popup : Control = SPLIT_POPUP_SCENE.instance()
		
		split_popup.rect_position = get_global_transform_with_canvas().origin + Vector2(0, rect_size.y)
		
		split_popup.from_slot = source_slot
		split_popup.to_slot = self
		
		add_child(split_popup)
		split_popup.show()
		return 
	
	
	if has_item():
		
		if item_handler.item.id == source_slot.item_handler.item.id:
			
			var amount := min(max_quantity - item_handler.quantity, source_slot.item_handler.quantity)
			
			var item : ItemHandler = source_slot.pick(amount)
			
			put(item, amount)
			
		else:
			
			var item_a : ItemHandler = source_slot.pick()
			var item_b : ItemHandler = pick()
			
			put(item_a)
			source_slot.put(item_b)
		
	else:
		
		var amount := min(max_quantity, source_slot.item_handler.quantity)
		
		var item : ItemHandler = source_slot.pick(amount)
		put(item, amount)
		


func has_item() -> bool:
	
	return item_handler != null
	


func can_equipe(item : ItemHandler) -> bool:
	if filter_type != "" and filter_category != "":
		return true if item.is_item_type(filter_type) and item.is_item_category(filter_category) else false
	elif filter_type != "":
		return item.is_item_type(filter_type)
	elif filter_category != "":
		return item.is_item_category(filter_category)
	return true


func pick(amount : int = -1) -> ItemHandler:
	
	amount = min(amount, item_handler.quantity)
	
	# Take all stack
	if has_item() and (amount == -1 or amount == item_handler.quantity):
		var result := item_handler
		remove_item_handler()
		return result
	
	# Split stack
	elif has_item():
		
		var result = ITEM_HANDLER_SCENE.instance()
		
		result.item = item_handler.item
		result.quantity = amount
		
		item_handler.set_quantity( item_handler.quantity - amount)
		
		return result
	
	return null


func put(new_item : ItemHandler, amount : int = -1) -> bool:
	
	if has_item():
		
		if new_item.item.id != item_handler.item.id:
			return false
		
		if max_quantity - item_handler.quantity < amount:
			return false
		
		item_handler.quantity += amount
		new_item.quantity -= amount
		
	else:
		set_item_handler(new_item)
	
	return true


func set_item_handler(new_item : ItemHandler):
	
	if new_item == null:
		remove_item_handler()
	
	item_handler = new_item
	item_handler.rect_position = Vector2.ZERO
	
	if item_handler.get_parent():
		item_handler.get_parent().remove_child(item_handler)
	
	add_child(item_handler)
	if max_quantity > 1:
		stack_label.visible = true
		stack_label.text = str(new_item.quantity)
	
	item_handler.connect("quantity_changed", self, "_on_quantity_changed")
	emit_signal("item_equiped", item_handler)


func remove_item_handler():
	if item_handler:
		var item := item_handler
		remove_child( item_handler )
		item_handler = null
		stack_label.visible = false
		emit_signal("item_unequiped", item)
		item.disconnect("quantity_changed", self, "_on_quantity_changed")


func set_max_quantity(value):
	
	max_quantity = max(1, value)
	


func _on_quantity_changed(quantity : int):
	
	stack_label.text = str(quantity)
	


func _on_mouse_entered():
	
	if has_item():
		
		var tooltip = TOOLTIP_SCENE.instance()
		
		add_child(tooltip)
		
		tooltip.rect_position = get_parent().get_global_transform_with_canvas().origin - Vector2(tooltip.rect_size.x, 0)
		
		tooltip.item = item_handler.item
		
		yield(get_tree().create_timer(0.35), "timeout")
		if has_node("ItemTooltip"):
			get_node("ItemTooltip").show()
	
	pass # Replace with function body.


func _on_mouse_exited():
	
	var tooltip = get_node("ItemTooltip")
	
	if tooltip:
		tooltip.queue_free()
	
	pass # Replace with function body.

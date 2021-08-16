class_name AbstractItemSlot
extends Panel


signal slot_action(type)


var TOOLTIP_SCENE = preload("res://scenes/ui/components/Inventory/ItemTooltip/ItemTooltip.tscn")
var ITEM_HANDLER_SCENE = preload("res://scenes/ui/components/Inventory/ItemHandler/ItemHandler.tscn")
var SPLIT_POPUP_SCENE = preload("res://scenes/ui/components/Inventory/ItemSplitPopup/ItemSplitPopup.tscn")

signal item_equiped(item)
signal item_unequiped(item)


export var filter_category := ""
export var filter_type := ""
export var unlimited_quantity := true
export var max_quantity := 1 setget set_max_quantity


onready var stack_label := $StackLabel
onready var hover := $HoverColorRect


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
			if has_item(): # if swap item
				if Input.is_action_pressed("secondary"): # if split asked
					if slot.item_handler.item.id == item_handler.item.id:
						return true
					else:
						return false
			else: # if slot empty
				return true
			return true
	return false


func drop_data(_pos, source_slot):
	
	#Open Split Screen
	if Input.is_action_pressed("secondary") and source_slot.item_handler.quantity > 1:
		
		var split_popup : Control = SPLIT_POPUP_SCENE.instance()
		
		split_popup.rect_position = get_global_transform_with_canvas().origin + Vector2(0, rect_size.y)
		
		split_popup.from_slot = source_slot
		split_popup.to_slot = self
		
		add_child(split_popup)
		
		var amount := min(get_item_max_quantity(source_slot.item_handler.item), source_slot.item_handler.quantity)
		
		split_popup.amount_label.text = str(amount / 2)
		
		split_popup.show()
		return 
	
	if has_item():
		
		# Transfer to same item type
		if item_handler.item.id == source_slot.item_handler.item.id and item_handler.item.max_stack > 1:
			item_transfer(source_slot)
		else: # Swap items
			item_swap(source_slot)
		
	else: # Transfert to empty slot
		item_give(source_slot)
		


func item_transfer(source_slot):
	
	var amount := int(min(get_item_max_quantity(source_slot.item_handler.item), source_slot.item_handler.quantity))
	
	var item : ItemHandler = source_slot.pick(amount)
	var _r = put(item, amount)


func item_swap(source_slot):
	var item_a : ItemHandler = source_slot.pick()
	var item_b : ItemHandler = pick()
	if item_a and  item_b:
		var _r = put(item_a)
		_r = source_slot.put(item_b)


func item_give(source_slot):
	
	var amount := int(min(get_item_max_quantity(source_slot.item_handler.item), source_slot.item_handler.quantity))
	
	var item : ItemHandler = source_slot.pick(amount)
	var _r = put(item, amount)


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


func put(new_item : ItemHandler, amount : int = -1) -> bool:
	
	if has_item():
		
		if new_item.item.id != item_handler.item.id:
			return false
		
		if unlimited_quantity:
			if item_handler.quantity < amount:
				return false
		elif max_quantity - item_handler.quantity < amount:
			return false
		
		item_handler.quantity += amount
		new_item.quantity -= amount
		
	else:
		set_item_handler(new_item)
	
	return true


func pick(amount : int = -1) -> ItemHandler:
	
	if item_handler == null:
		return null
	
	amount = int(min(amount, item_handler.quantity))
	
	# Take all stack
	if has_item() and (amount == -1 or amount == item_handler.quantity):
		var result := item_handler
		remove_item_handler()
		return result
	
	# Split stack
	elif has_item():
		var result = ITEM_HANDLER_SCENE.instance()
		result.item = item_handler.item
		result.attributes = item_handler.attributes
		result.quantity = amount
		item_handler.set_quantity( item_handler.quantity - amount)
		
		return result
	
	return null


func set_item_handler(new_item : ItemHandler):
	
	if new_item == null:
		var old_item_hander = item_handler
		remove_item_handler()
		old_item_hander.queue_free()
	
	item_handler = new_item
	item_handler.rect_position = Vector2.ZERO
	
	if item_handler.get_parent():
		item_handler.get_parent().remove_child(item_handler)
	
	add_child(item_handler)
	if new_item.quantity > 1:
		stack_label.visible = true
		stack_label.text = str(new_item.quantity)
	
	var _r := item_handler.connect("quantity_changed", self, "_on_quantity_changed")
	emit_signal("item_equiped", item_handler)


func remove_item_handler():
	if has_item():
		var old_item := item_handler
		remove_child( item_handler )
		item_handler = null
		stack_label.visible = false
		emit_signal("item_unequiped", old_item)
		old_item.disconnect("quantity_changed", self, "_on_quantity_changed")
		old_item.queue_free()


func get_item_max_quantity(item : GameItem) -> int:
	if has_item():
		if unlimited_quantity:
			return int(min(item_handler.quantity, item.max_stack))
		else:
			
			return int(min(max_quantity, item.max_stack)) - item_handler.quantity
			
			#return int(min(min(item_handler.quantity, max_quantity), item.max_stack))
	else:
		if unlimited_quantity:
			return item.max_stack
		else:
			return int(min(max_quantity, item.max_stack))


func _calculate_amount(amount : int, _item_handler : ItemHandler) -> int:
	if max_quantity > 0:
		return int(min(min(min(amount, max_quantity), item_handler.quantity), item_handler.item.max_stack))
	else:
		return int(min(min(amount, item_handler.quantity), item_handler.item.max_stack))


func set_max_quantity(value):
	
	max_quantity = int(max(1, value))
	


func _on_quantity_changed(quantity : int):
	
	stack_label.text = str(quantity)
	


func _on_mouse_entered():
	
	if has_item():
		
		hover.visible = true
		
		var tooltip = TOOLTIP_SCENE.instance()
		
		add_child(tooltip)
		tooltip.name = "ItemTooltip"
		tooltip.rect_position = get_parent().get_global_transform_with_canvas().origin - Vector2(tooltip.rect_size.x, 0)
		tooltip.item = item_handler.item
		tooltip.rarity = item_handler.rarity
		tooltip.attributes = item_handler.attributes
		
		yield(get_tree().create_timer(0.35), "timeout")
		if has_node("ItemTooltip"):
			get_node("ItemTooltip").show()
	
	pass # Replace with function body.


func _on_mouse_exited():
	if has_node("ItemTooltip"):
		var tooltip = get_node("ItemTooltip")
		tooltip.queue_free()
	hover.visible = false


func _on_gui_input(event):
	
	if has_item():
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == BUTTON_RIGHT:
				emit_signal("slot_action", "secondary")

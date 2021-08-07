extends Popup


onready var amount_label := $HBoxContainer/Amount
onready var confirm_button := $HBoxContainer/Confirm



var from_slot
var to_slot


# Called when the node enters the scene tree for the first time.
func _ready():
	
	amount_label.text = ""
	amount_label.grab_focus()
	
	from_slot.connect("item_unequiped", self, "_on_item_unequiped")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	
	if event.is_action_pressed("ui_accept"):
		_on_Confirm_pressed()
	if event.is_action_pressed("ui_cancel"):
		queue_free()


func _on_Confirm_pressed():
	
	if from_slot.has_item():
		
		var amount : int = amount_label.text.to_int() if amount_label.text != "" else 1
		
		var split_amount := clamp(amount, 1, from_slot.item_handler.quantity-1)
		
		if to_slot.has_item():
			split_amount = min(split_amount, to_slot.max_quantity - to_slot.item_handler.quantity)
		
		var item = from_slot.pick(split_amount)
		to_slot.put(item, split_amount)
	
	queue_free()
	


func _on_ItemSplitPopup_visibility_changed():
	
	if visible:
		
		$AnimationPlayer.play("fade_in")
		
	
	pass # Replace with function body.


func _on_item_unequiped(item):
	
	queue_free()
	

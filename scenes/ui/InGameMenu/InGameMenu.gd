extends Control


signal inventory_clicked
signal help_clicked


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _unhandled_input(event):
	
	$MarginContainer/HBoxContainer/InventoryButton.release_focus()
	$MarginContainer/HBoxContainer/HelpButton.release_focus()
	


func _on_InventoryButton_pressed():
	
	emit_signal("inventory_clicked")
	


func _on_HelpButton_pressed():
	
	emit_signal("help_clicked")
	

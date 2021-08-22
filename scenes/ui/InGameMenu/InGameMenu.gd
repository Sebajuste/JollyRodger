extends Control


signal inventory_clicked
signal help_clicked


onready var inventory_btn := $MarginContainer/HBoxContainer/InventoryButton
onready var help_btn := $MarginContainer/HBoxContainer/HelpButton



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _gui_input(_event):
	
	if inventory_btn.has_focus():
		inventory_btn.release_focus()
		get_tree().set_input_as_handled()
	
	if help_btn.has_focus():
		help_btn.release_focus()
		get_tree().set_input_as_handled()
	


func _on_InventoryButton_pressed():
	inventory_btn.release_focus()
	emit_signal("inventory_clicked")
	


func _on_HelpButton_pressed():
	help_btn.release_focus()
	emit_signal("help_clicked")
	

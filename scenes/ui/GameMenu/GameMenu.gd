extends Control


onready var options_window := $OptionsWindow


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_QuitButton_pressed():
	
	get_tree().quit()
	
	pass # Replace with function body.


func _on_OptionsButton_pressed():
	
	options_window.popup_centered()
	

extends WindowDialog


signal change_faction_clicked
signal options_clicked
signal quitgame_clicked


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ChangeFactionButton_pressed():
	emit_signal("change_faction_clicked")
	hide()


func _on_OptionsButton_pressed():
	emit_signal("options_clicked")
	hide()


func _on_QuitGameButton_pressed():
	emit_signal("quitgame_clicked")
	hide()


func _on_ResumeButton_pressed():
	
	hide()
	

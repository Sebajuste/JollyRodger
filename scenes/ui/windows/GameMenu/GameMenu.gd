extends WindowDialog


signal change_faction_clicked
signal options_clicked
signal quitgame_clicked
signal ship_scuttled


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
	


func _on_ScuttleFactionButton_pressed():
	
	var cd := ConfirmationDialog.new()
	
	cd.dialog_text = "Etes vous sur de vouloir détruire votre navire ?"
	cd.popup_exclusive = true
	
	var cancel_btn := cd.get_cancel()
	cancel_btn.rect_min_size = Vector2(150, 40)
	cancel_btn.text = "btn_cancel"
	
	var ok_btn = cd.get_ok()
	ok_btn.rect_min_size = Vector2(150, 40)
	ok_btn.text = "btn_confirm"
	
	var _r
	_r = cd.connect("popup_hide", self, "_on_hide_confirmation", [cd])
	_r = cd.connect("confirmed", self, "_on_scuttle", [cd])
	
	add_child(cd)
	
	cd.popup_centered()
	
	self.hide()
	pass # Replace with function body.


func _on_scuttle(cd):
	cd.queue_free()
	emit_signal("ship_scuttled")
	

func _on_hide_confirmation(cd):
	self.show()
	cd.queue_free()
	


extends WindowDialog


onready var sound_tab := $MarginContainer/VBoxContainer/TabContainer/Sound
onready var display_tab := $MarginContainer/VBoxContainer/TabContainer/Display
onready var game_tab := $MarginContainer/VBoxContainer/TabContainer/Game


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var _r := Configuration.connect("configuration_changed", self, "_on_configuration_changed")
	
	update_title_translation()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func update_title_translation():
	
	sound_tab.name = tr("title_sound")
	display_tab.name = tr("title_display")
	game_tab.name = tr("title_game")
	


func _on_configuration_changed():
	
	update_title_translation()
	



func _on_about_to_show():
	
	update_title_translation()
	


func _on_RestoreDefaultButton_pressed():
	
	pass # Replace with function body.


func _on_SaveButton_pressed():
	
	Configuration.save_settings()
	


func _on_CloseButton_pressed():
	
	hide()
	

extends Node


#signal resource_loaded(resource)

onready var progress_bar := $VBoxContainer/Control/MarginContainer/VBoxContainer/ProgressBar


#var loader : ResourceInteractiveLoader


func on_load_progress(stage, stage_count):
	progress_bar.max_value = stage_count
	progress_bar.value  = stage


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Loading.connect("on_progress", self, on_load_progress)
	
	pass # Replace with function body.




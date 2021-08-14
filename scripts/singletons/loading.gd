extends Node

const LOADING_SCENE = "res://scenes/ui/Loading/Loading.tscn"


signal on_progress(stage, stage_count)


var loader : ResourceInteractiveLoader


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if not loader:
		return
	
	var result := loader.poll()
	
	emit_signal("on_progress", loader.get_stage(), loader.get_stage_count() )
	
	if result == ERR_FILE_EOF:
		var resource = loader.get_resource()
		#var instance = resource.instance()
		#get_tree().change_scene(instance)
		var _r := get_tree().change_scene_to(resource)
		loader = null


func load_scene(scene_path : String):
	
	var _r := get_tree().change_scene(LOADING_SCENE)
	
	loader = ResourceLoader.load_interactive("res://%s" % scene_path)
	
	pass

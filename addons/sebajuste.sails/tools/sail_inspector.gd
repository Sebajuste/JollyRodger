extends EditorInspectorPlugin


const SAIL_CONTROLS_SCENE := preload("res://addons/sebajuste.sails/tools/SailControls.tscn")
const SAIL_CONTROL_SCENE := preload("res://addons/sebajuste.sails/tools/SailControl.tscn")

func can_handle(object):
	
	return object is Sail
	


func parse_begin(object):
	
	
	pass

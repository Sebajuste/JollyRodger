# SailGizmoPlugin.gd
extends EditorSpatialGizmoPlugin


var SailGizmo = preload("SailGizmo.gd")


func _init():
	create_material("main", Color(1, 0, 0))
	create_handle_material("handles")


func get_name():
	return "SailNode"


func has_gizmo(spatial):
	return spatial is Sail


func create_gizmo(spatial):
	if spatial is Sail:
		return SailGizmo.new()
	else:
		return null

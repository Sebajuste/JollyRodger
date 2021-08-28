# SailGizmo.gd
class_name SailGizmo
extends EditorSpatialGizmo


# You can store data in the gizmo itself (more useful when working with handles).
var gizmo_size = 3.0


func redraw():
	print("redraw SailGizmo")
	clear()
	
	var sail : Sail = get_spatial_node()
	
	var lines = PoolVector3Array()
	
	
	print("sail.width : ", sail.width)
	print("sail.height : ", sail.height)
	
	lines.push_back(Vector3(0, 0, 0))
	lines.push_back(Vector3(sail.width, 0, 0))
	
	lines.push_back(Vector3(sail.width, 0, 0))
	lines.push_back(Vector3(sail.width, -sail.height, 0))
	
	lines.push_back(Vector3(sail.width, -sail.height, 0))
	lines.push_back(Vector3(0, -sail.height, 0))
	
	lines.push_back(Vector3(0, -sail.height, 0))
	lines.push_back(Vector3(0, 0, 0))
	
	for spring in sail.springs:
		lines.push_back( spring.a.position )
		lines.push_back( spring.b.position )
	
	
	var handles = PoolVector3Array()
	
	print("> spatial.spring_nodes.size() : ", sail.spring_bounds.size() )
	"""
	for spring_node in spatial.spring_bounds:
		handles.push_back( spring_node.position )
		pass
	"""
	
	handles.push_back( Vector3(0, 0, 0) )
	handles.push_back( Vector3(sail.width, 0, 0) )
	handles.push_back( Vector3(sail.width, -sail.height, 0) )
	handles.push_back( Vector3(0, -sail.height, 0) )
	
	
	
	var material = get_plugin().get_material("main", self)
	add_lines(lines, material, false)
	
	var handles_material = get_plugin().get_material("handles", self)
	add_handles(handles, handles_material)


func commit_handle(index: int, restore, cancel: bool = false):
	
	print("commit_handle [%s]" % index, " restore : ", restore, ", cancel : ", cancel)
	
	pass


func get_handle_name(index : int):
	print("get_handle_name ", index)
	return "SailBound%d" % index


func get_handle_value(index : int):
	print("get_handle_value ", index)
	var spatial = get_spatial_node()
	return spatial.spring_bounds[index].position
	#return null


func set_handle(index: int, camera: Camera, point: Vector2):
	
	print("set_handle ", index, ", point ", point )
	
	pass




# You should implement the rest of handle-related callbacks
# (get_handle_name(), get_handle_value(), commit_handle()...).

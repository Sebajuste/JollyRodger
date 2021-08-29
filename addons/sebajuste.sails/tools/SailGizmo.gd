# SailGizmo.gd
class_name SailGizmo
extends EditorSpatialGizmo


# You can store data in the gizmo itself (more useful when working with handles).
#var gizmo_size = 3.0


func redraw():
	print("redraw SailGizmo")
	clear()
	
	var sail : Sail = get_spatial_node()
	
	var lines = PoolVector3Array()
	
	for spring in sail.springs:
		lines.push_back( spring.a.position )
		lines.push_back( spring.b.position )
	
	var handles = PoolVector3Array()
	
	handles.push_back( sail.up_right_position )
	handles.push_back( sail.up_left_position )
	handles.push_back( sail.bottom_left_position )
	handles.push_back( sail.bottom_right_position )
	
	
	
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
	
	var sail : Sail = get_spatial_node()
	
	#var a : Vector3 = (sail.up_right_position - sail.up_left_position)
	#var b : Vector3 = (sail.up_right_position - sail.bottom_right_position)
	
	var p1 := sail.global_transform * Transform(Basis(), sail.up_right_position+sail.global_transform.origin)
	var p2 := sail.global_transform * Transform(Basis(), sail.up_left_position+sail.global_transform.origin)
	var p3 := sail.global_transform * Transform(Basis(), sail.bottom_right_position+sail.global_transform.origin)
	
	#var a : Vector3 = (sail.up_right_position+sail.global_transform.origin) - (sail.up_left_position+sail.global_transform.origin)
	#var b : Vector3 = (sail.up_right_position+sail.global_transform.origin) - (sail.bottom_right_position+sail.global_transform.origin)
	
	var a := p1.origin - p2.origin
	var b := p1.origin - p3.origin
	
	var normal := a.cross(b).normalized()
	
	#print("normal : ", normal)
	
	var distance := normal.dot(sail.global_transform.origin)
	
	#print("distance : ", distance, " -> ", sail.global_transform.origin.length() )
	
	#print("set_handle ", index, ", point ", point )
	
	var from := camera.project_ray_origin(point)
	var to := camera.project_ray_normal(point)
	
	var plane := Plane(normal, sail.global_transform.origin.length() )
	
	#var new_pos := Plane.PLANE_XY.intersects_ray(from, to.normalized())
	
	var new_pos := plane.intersects_ray(from, to.normalized())
	
	print("from : ", from)
	print("to : ", to.normalized() )
	print("new_pos : ", new_pos)
	
	pass




# You should implement the rest of handle-related callbacks
# (get_handle_name(), get_handle_value(), commit_handle()...).

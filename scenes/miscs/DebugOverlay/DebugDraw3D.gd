extends Control


class Vector:
	var spatial_ref
	var object_ref
	var property
	var scale
	var width
	var color
	
	func _init(_spatial, _object, _property, _scale, _width, _color):
		spatial_ref = weakref(_spatial)
		object_ref = weakref(_object)
		property = _property
		scale = _scale
		width = _width
		color = _color
	
	
	func is_valid() -> bool:
		
		return spatial_ref.get_ref() and object_ref.get_ref()
		
	
	
	func draw(node : Control, camera : Camera):
		
		var spatial = spatial_ref.get_ref()
		var object = object_ref.get_ref()
		
		if spatial == null or object == null:
			# TODO : remove this Vector
			return
		
		if not spatial.is_inside_tree():
			return
		
		var cam_dir = (camera.global_transform.origin - spatial.global_transform.origin).normalized()
		var cam_dot = cam_dir.dot( camera.global_transform.basis.z )
		
		var properties = property.split(":")
		var value = object.get_indexed(properties[0])
		for i in range(1, len(properties) ):
			match typeof(value):
				TYPE_ARRAY:
					value = value[int(properties[i])]
				_:
					value = value[properties[i]]
		
		#var value = object.get(property)
		if cam_dot > 0.0 and value != null:
			var start := camera.unproject_position(spatial.global_transform.origin)
			var end := camera.unproject_position(spatial.global_transform.origin + value * scale)
			node.draw_line(start, end, color, width)
			node._draw_triangle(end, start.direction_to(end), width*2, color)


var vectors := []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if visible:
		update()


func _draw():
	var camera := get_viewport().get_camera()
	if camera:
		for index in range(vectors.size()-1, -1, -1):
			var vector : Vector = vectors[index]
			if vector.is_valid():
				vector.draw(self, camera)
			else:
				vectors.remove(index)


func _draw_triangle(pos : Vector2, dir : Vector2, size : float, color : Color):
	var a = pos + dir * size
	var b = pos + dir.rotated(2*PI/3) * size
	var c = pos + dir.rotated(4*PI/3) * size
	var points = PoolVector2Array([a, b, c])
	draw_polygon(points, PoolColorArray([color]))


func _get_object_nodepath(path : String) -> String:
	var end_path := path.find_last("/")
	if end_path > -1:
		return path.substr(0, end_path)
	else:
		return path


func _get_object_property(path : String) -> String:
	var end_path := path.find_last("/")
	if end_path > -1:
		return path.substr(end_path + 1)
	return path



func add_vector(spatial : Spatial, property : String, scale : float, width : float, color := Color.white):
	var idx := find_vector(spatial, property)
	if idx == -1:
		var object_path := _get_object_nodepath(property)
		if object_path.find_last("/") != -1:
			property = _get_object_property(property)
			var object = spatial.get_node(object_path)
			vectors.append( Vector.new(spatial, object, property, scale, width, color) )
		else:
			vectors.append( Vector.new(spatial, spatial, property, scale, width, color) )


func remove_vector(spatial : Spatial, property : String):
	var idx := find_vector(spatial, property)
	if idx > -1:
		vectors.remove(idx)


func find_vector(object : Object, property : String) -> int:
	for index in range(vectors.size()):
		var vector : Vector = vectors[index]
		if vector.object_ref.get_ref() == object and vector.property == property:
			return index
	return -1


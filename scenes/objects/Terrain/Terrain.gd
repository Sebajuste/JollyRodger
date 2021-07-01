tool
extends Spatial


export var noise : OpenSimplexNoise setget set_noise
export var size := Vector2(400, 400) setget set_size
export var height := 30.0 setget set_height
export(Curve) var height_curve : Curve
export(Curve) var island_curve : Curve
export(float, 0.1, 10.0) var level_of_details := 1.0 setget set_level_of_details
export var material : Material setget set_material



onready var mesh_instance : MeshInstance = $MeshInstance


var _need_generate := false


var thread_generation : Thread
var thread_mutex : Mutex = Mutex.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	
	generate_terrain()
	
	pass # Replace with function body.


func _exit_tree():
	if thread_generation:
		thread_generation.wait_to_finish()


func generate_terrain():
	print("generate_terrain, _need_generate: ", _need_generate)
	thread_mutex.lock()
	if not _need_generate:
		#call_deferred("_deferred_generate_terrain")
		print("terrain generation start thread")
		thread_generation = Thread.new()
		var error := thread_generation.start(self, "_thread_generation", noise)
		print("thread started with : ", error)
	_need_generate = true
	thread_mutex.unlock()


func _thread_generation(noise):
	
	print("terrain is generate...")
	
	if not noise:
		return
	
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = size
	plane_mesh.subdivide_width = size.x * level_of_details
	plane_mesh.subdivide_depth = size.y * level_of_details
	
	var surface_tool := SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	
	var array_plane : ArrayMesh = surface_tool.commit()
	
	var data_tool := MeshDataTool.new()
	data_tool.create_from_surface(array_plane, 0)
	
	var center_position := Vector2.ZERO
	var max_center_distance := Vector2(size.x / 2.0, 0.0).length()
	
	# Create data from noise
	for index in range(data_tool.get_vertex_count()):
		var vertex := data_tool.get_vertex(index)
		
		
		var noise_height = ((noise.get_noise_2d(vertex.x, vertex.z)) + 1.0) / 2.0
		
		var island_factor := 1.0
		if island_curve:
			var vertex_center_distance := Vector2(vertex.x, vertex.z).distance_to( center_position )
			var curve_position := vertex_center_distance / max_center_distance
			
			island_factor = island_curve.interpolate( 1.0 - curve_position )
		
		if height_curve:
			vertex.y = height_curve.interpolate(noise_height) * height * island_factor
		else:
			vertex.y = noise_height * height * island_factor
		
		#vertex.x = vertex.x / level_of_details
		#vertex.z = vertex.z / level_of_details
		data_tool.set_vertex(index, vertex)
	
	
	# TODO : call erosion
	#data_tool = _fast_erode(array_plane, data_tool, iteration)
	
	
	# Create plane from data
	for index in range(array_plane.get_surface_count()):
		array_plane.surface_remove(index)
	data_tool.commit_to_surface(array_plane)
	
	# Create final surface
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	
	
	
	
	
	var collision_shape := HeightMapShape.new()
	
	var map_data := PoolRealArray()
	map_data.resize( data_tool.get_vertex_count() )
	
	for index in range(data_tool.get_vertex_count()):
		map_data[index] = data_tool.get_vertex(index).y
	
	
	collision_shape.map_width = size.x * level_of_details + 2
	collision_shape.map_depth = size.y * level_of_details + 2
	collision_shape.set_map_data( map_data )
	
	var array_mesh = surface_tool.commit()
	#$MeshInstance.mesh = surface_tool.commit()
	#$MeshInstance.material_override = material
	
	#$StaticBody/CollisionShape.shape = collision_shape
	#$StaticBody/CollisionShape.transform.basis = Transform().rotated(Vector3(0, 1, 0), PI).scaled( Vector3(1 / level_of_details, 1.0, 1 / level_of_details) ).basis
	
	# = $StaticBody/CollisionShape.transform.scaled( Vector3(1 / level_of_details, 1.0, 1 / level_of_details) )
	
	surface_tool.clear()
	data_tool.clear()
	
	thread_mutex.lock()
	_need_generate = false
	print("generation done")
	thread_mutex.unlock()
	
	self.call_deferred("_update_nodes", array_mesh, collision_shape)


func _update_nodes(array_mesh : ArrayMesh, collision_shape : HeightMapShape):
	print("_update_nodes")
	$MeshInstance.mesh = array_mesh
	$MeshInstance.material_override = material
	$StaticBody/CollisionShape.shape = collision_shape
	$StaticBody/CollisionShape.transform.basis = Transform().rotated(Vector3(0, 1, 0), PI).scaled( Vector3(1 / level_of_details, 1.0, 1 / level_of_details) ).basis
	pass


func set_noise(value):
	noise = value
	if value != null:
		generate_terrain()


func set_size(value):
	size = value
	if value != null:
		generate_terrain()


func set_height(value):
	height = value
	generate_terrain()


func set_level_of_details(value):
	level_of_details = max(0.1, value)
	generate_terrain()


func set_material(value):
	material = value
	if value != null and mesh_instance:
		mesh_instance.material_override = value

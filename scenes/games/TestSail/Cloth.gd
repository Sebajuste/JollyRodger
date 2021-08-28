extends Spatial


var CLOTH_NODE_SCENE = preload("ClothNode.tscn")


export var width := 5.0
export var height := 2.0
export var size := 5
export var tightness : float = 1.0 setget set_tightness
export var damp : float = 20.0 setget set_damp
export var gravity := 9.8
export(float, 0.1, 1.0, 0.01) var update_frame := 1.0
export var wind := Vector3.ZERO


onready var debug := $Debug


var spring_nodes := []
var springs := []

var frame_count := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	#length = width / float(size)
	
	#$MeshInstance.set_as_toplevel(true)
	#$ImmediateGeometry.set_as_toplevel(true)
	create_springs()
	create_mesh()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(delta):
	
	var frame_ratio := 1 / update_frame
	frame_count += 1
	
	if frame_count == frame_ratio:
		frame_count = 0
	else:
		return
	
	for spring in springs:
		spring.update(delta)
	
	var rot_euler := global_transform.basis.get_euler()
	var local_wind := wind.rotated(Vector3.UP, -rot_euler.y)
	
	for node in spring_nodes:
		if node.dynamic:
			node.velocity += local_wind * delta + Vector3.DOWN*gravity * delta
	
	create_mesh()
	
	pass


func create_springs():
	
	#var count_per_line := int(sqrt(count))
	
	var vertex_count := size*size
	
	var vertex_spacing_x := width / float(size)
	var vertex_spacing_y := height/ float(size)
	
	#var local_length := size / count_per_line
	
	# Create mesh
	for index in range(vertex_count):
		
		var x := int(index % size)
		var y := int(index / size)
		
		var pos := Vector3(
			x*vertex_spacing_x,
			-y*vertex_spacing_y,
			0.0
		)
		
		var n := Spring.SpringNode.new(pos)
		spring_nodes.append(n)
		
		# For debug
		var node : Spatial = CLOTH_NODE_SCENE.instance()
		node.spring_node = n
		node.transform.origin = pos
		debug.add_child(node)
	
	
	# Create springs
	for index in range(vertex_count):
		
		var x := int(index % size)
		var y := int(index / size)
		
		var node = spring_nodes[index]
		
		if x < size-1:
			var node_right = spring_nodes[index+1]
			if not has_spring(node, node_right):
				create_spring(node, node_right)
		
		if x > 0:
			var node_left = spring_nodes[index-1]
			if not has_spring(node, node_left):
				create_spring(node, node_left)
		
		if y < size-1:
			var node_down = spring_nodes[index+size]
			if not has_spring(node, node_down):
				create_spring(node, node_down)
		
		if y > 0:
			var node_up = spring_nodes[index-size]
			if not has_spring(node, node_up):
				create_spring(node, node_up)
	
	
	for index in size:
		spring_nodes[index].dynamic = false
	
	"""
	#spring_nodes[0].set_as_toplevel(false)
	spring_nodes[1].dynamic = false
	#spring_nodes[1].set_as_toplevel(false)
	spring_nodes[2].dynamic = false
	#spring_nodes[2].set_as_toplevel(false)
	spring_nodes[3].dynamic = false
	#spring_nodes[3].set_as_toplevel(false)
	spring_nodes[4].dynamic = false
	#spring_nodes[4].set_as_toplevel(false)
	"""
	
	spring_nodes[size*size-size].dynamic = false
	
	spring_nodes[ size*size-1 ].dynamic = false
	
	"""
	spring_nodes[0+20].dynamic = false
	#spring_nodes[0+20].set_as_toplevel(false)
	spring_nodes[1+20].dynamic = false
	#spring_nodes[1+20].set_as_toplevel(false)
	spring_nodes[2+20].dynamic = false
	#spring_nodes[2+20].set_as_toplevel(false)
	spring_nodes[3+20].dynamic = false
	#spring_nodes[3+20].set_as_toplevel(false)
	spring_nodes[4+20].dynamic = false
	#spring_nodes[4+20].set_as_toplevel(false)
	"""


func create_mesh():
	
	#var count_per_line := int(sqrt(count))
	var count_per_line := size
	
	var uv_max := float(count_per_line-1)
	
	var st = SurfaceTool.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	
	# Create all vertex
	for index in range(spring_nodes.size()):
		
		var x := int(index % count_per_line)
		var y := int(index / count_per_line)
		
		st.add_uv( Vector2(x/uv_max, y/uv_max) )
		st.add_vertex( spring_nodes[index].position )
	
	
	# Draw all squares using vertex index
	for index in range(spring_nodes.size()):
		
		var x := int(index % count_per_line)
		var y := int(index / count_per_line)
		
		if x >= count_per_line - 1:
			continue
		if y >= count_per_line - 1:
			continue
		
		#
		# Triangle 1
		#
		
		# Vertex1
		st.add_index(index)
		
		# Vertex2
		st.add_index(index+count_per_line)
		
		# Vertex3
		st.add_index(index+1)
		
		#
		# Triangle 2
		#
		
		# Vertex1
		st.add_index(index+1)
		
		# Vertex2
		st.add_index(index+count_per_line)
		
		# Vertex3
		st.add_index(index+count_per_line+1)
		
		pass
	
	st.generate_normals()
	st.generate_tangents()
	
	var mesh = st.commit()
	
	$MeshInstance.mesh = mesh
	
	pass


func update_mesh():
	
	var mesh : ArrayMesh = $MeshInstance.mesh
	
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, Mesh.PRIMITIVE_POINTS)
	
	for index in range(mdt.get_face_count()):
		#var vert = mdt.get_vertex(index)
		
		# Vertex 1
		
		var i := int(index / 2)
		
		if index % 2 == 0:
			var idx : int = mdt.get_face_vertex(index, 0)
			print(index, " @ [%d] " % i, idx, mdt.get_vertex(idx), " -> ", spring_nodes[i].position )
		
		# Vertex 2
		
		# Vertex 3
		
		#update_vertex(mdt, index, 0)
		#update_vertex(mdt, index, 1)
		#update_vertex(mdt, index, 2)
		
		#vert *= 2.0 # Scales the vertex by doubling size.
		#mdt.set_vertex(index, spring_nodes[index].position)
		pass
	
	mesh.surface_remove(0) # Deletes the first surface of the mesh.
	mdt.commit_to_surface(mesh)
	
	pass


func update_vertex(mdt: MeshDataTool, index : int, vertex : int):
	
	var idx := mdt.get_face_vertex(index, vertex) 
	
	var spring_idx := 0
	
	
	
	print(index, " -> ", idx, mdt.get_vertex(idx) )
	
	pass



func has_spring(a, b) -> bool:
	for spring in springs:
		if (spring.a == a and spring.b == b) or (spring.a == b and spring.b == a):
			return true
	return false


func create_spring(a, b):
	if not a or not b:
		push_error("Invalid node for spring")
		return
	
	var spring := Spring.new(a, b, tightness, damp)
	springs.append(spring)
	pass


func set_tightness(value):
	tightness = max(0.1, value)
	for spring in springs:
		spring.tightness = tightness


func set_damp(value):
	damp = max(0.1, value)
	for spring in springs:
		spring.damp = damp

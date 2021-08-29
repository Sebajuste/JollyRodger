tool
class_name Sail
extends Spatial


#export var width := 2.0 setget set_width
export var height := 2.0 setget set_height
export var size := 2 setget set_size

export var fix_upper := false
export var fix_right := false
export var fix_left := false
export var fix_bottom := false
export var fix_upper_right := false
export var fix_upper_left := false
export var fix_bottom_right := false
export var fix_bottom_left := false

export var tightness : float = 1.0 setget set_tightness
export var damp : float = 20.0 setget set_damp
export var gravity := 9.8
export(float, 0.1, 1.0, 0.01) var update_frame := 1.0
export var wind := Vector3.ZERO
export var material : Material setget set_material

export var up_right_position := Vector3(0, 0, 0)
export var up_left_position := Vector3(1, 0, 0)
export var bottom_right_position := Vector3(0, -1, 0)
export var bottom_left_position := Vector3(1, -1, 0)


var mesh_instance := MeshInstance.new()
var spring_bounds := []
var springs := []

var frame_count := 0


func _init():
	set_notify_transform(true)
	if Engine.editor_hint:
		set_physics_process(false)
	


# Called when the node enters the scene tree for the first time.
func _ready():
	print("_ready")
	add_child(mesh_instance)
	create_springs()
	create_mesh()
	
	if Engine.editor_hint:
		set_physics_process(false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _physics_process(delta):
	
	print("_physics_process")
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
	
	for node in spring_bounds:
		if node.dynamic:
			node.velocity += local_wind * delta + Vector3.DOWN*gravity * delta
	
	create_mesh()
	
	pass


func create_sail():
	print("create_sail")
	create_springs()
	create_mesh()
	update_gizmo()


func create_springs():
	
	print("create_springs")
	
	var vertex_count : int = (size+1)*(size+1)
	
	print("vertex_count : ", vertex_count)
	
	
	var up_width := up_left_position - up_right_position
	var bottom_width := bottom_left_position - bottom_right_position
	
	var up_width_spacing := up_width / float(size)
	var bottom_width_spacing := bottom_width / float(size)
	
	var right_height := bottom_right_position - up_right_position
	var left_height := bottom_left_position - up_left_position
	
	var right_height_spacing := right_height / float(size)
	var left_height_spacing := left_height / float(size)
	
	spring_bounds.clear()
	springs.clear()
	
	# Create vertex
	for index in range(vertex_count):
		
		var x := int(index % (size+1))
		var y := int(index / (size+1))
		
		var from := up_right_position + right_height_spacing*y
		var to := up_left_position + left_height_spacing*y
		
		var delta := to - from
		var delta_spacing := delta / float(size)
		
		var pos := from + delta_spacing*x
		
		#var h1 := y * right_height_spacing
		#var h2 := y * left_height_spacing
		
		
		
		"""
		var width := up_left_position.x - up_right_position.x
		var vertex_spacing_x := width / float(size)
		
		var height := up_left_position.y - bottom_left_position.y
		var vertex_spacing_y := height/ float(size)
		
		var pos := Vector3(
			x*vertex_spacing_x,
			-y*vertex_spacing_y,
			0.0
		)
		"""
		var n := SailSpringBound.new(pos)
		spring_bounds.append(n)
		
	
	
	# Create springs
	for index in range(vertex_count):
		
		var x := int(index % (size+1))
		var y := int(index / (size+1))
		
		var node = spring_bounds[index]
		
		if x < size-1:
			var node_right = spring_bounds[index+1]
			if not has_spring(node, node_right):
				create_spring(node, node_right)
		
		if x > 0:
			var node_left = spring_bounds[index-1]
			if not has_spring(node, node_left):
				create_spring(node, node_left)
		
		if y < size-1:
			var node_down = spring_bounds[index+(size+1)]
			if not has_spring(node, node_down):
				create_spring(node, node_down)
		
		if y > 0:
			var node_up = spring_bounds[index-(size+1)]
			if not has_spring(node, node_up):
				create_spring(node, node_up)
	
	"""
	if fix_upper:
		for index in (size+1):
			spring_bounds[index].dynamic = false
	
	if fix_bottom:
		for index in range(spring_bounds.size() - size - 1, spring_bounds.size()):
			spring_bounds[index].dynamic = false
	"""
	
	if fix_upper_right:
		spring_bounds[0].dynamic = false
	if fix_upper_left:
		spring_bounds[size].dynamic = false
	if fix_bottom_right:
		spring_bounds[spring_bounds.size()-1].dynamic = false
	if fix_bottom_left:
		spring_bounds[spring_bounds.size()-size-1].dynamic = false
	
	for index in spring_bounds.size():
		if fix_upper and index < size+1:
			spring_bounds[index].dynamic = false
		if fix_bottom and index > spring_bounds.size() - size - 1:
			spring_bounds[index].dynamic = false
		if fix_right and index % (size+1) == 0:
			spring_bounds[index].dynamic = false
		if fix_left and index % (size+1) == size:
			spring_bounds[index].dynamic = false


func create_mesh():
	
	var count_per_line := size+1
	
	var uv_max := float(count_per_line-1)
	
	var st = SurfaceTool.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	
	# Create all vertex
	for index in range(spring_bounds.size()):
		
		var x := int(index % count_per_line)
		var y := int(index / count_per_line)
		
		st.add_uv( Vector2(x/uv_max, y/uv_max) )
		st.add_vertex( spring_bounds[index].position )
	
	
	# Draw all squares using vertex index
	for index in range(spring_bounds.size()):
		
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
	
	mesh_instance.mesh = st.commit()
	mesh_instance.mesh.surface_set_material(0, material)
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
	
	var spring := SailSpring.new(a, b, tightness, damp)
	springs.append(spring)
	pass

"""
func set_width(value):
	width = abs(value)
	create_sail()
"""

func set_height(value):
	height = abs(value)
	create_sail()


func set_size(value):
	size = clamp(value, 0, 100)
	create_sail()


func set_tightness(value):
	tightness = max(0.1, value)
	for spring in springs:
		spring.tightness = tightness


func set_damp(value):
	damp = max(0.1, value)
	for spring in springs:
		spring.damp = damp


func set_material(value):
	material = value
	mesh_instance.material_override = material

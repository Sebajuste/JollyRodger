extends Spatial


var CLOTH_NODE_SCENE = preload("ClothNode.tscn")


export var length : float = 3.0
export var tightness : float = 1.0
export var damp : float = 20.0
export var gravity := 9.8
export var wind := Vector3.ZERO


onready var debug := $Debug


var spring_nodes := []
var springs := []


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var n1 := Spring.SpringNode.new(Vector3(0, 0, 0), false)
	spring_nodes.append(n1)
	
	# For debug
	var node : Spatial = CLOTH_NODE_SCENE.instance()
	node.spring_node = n1
	node.transform.origin = Vector3(0, 0, 0)
	debug.add_child(node)
	
	
	var n2 := Spring.SpringNode.new(Vector3(0, -3, 0))
	spring_nodes.append(n2)
	
	# For debug
	node = CLOTH_NODE_SCENE.instance()
	node.spring_node = n2
	node.transform.origin = Vector3(0, -3, 0)
	debug.add_child(node)
	
	
	create_spring(n1, n2)
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(delta):
	for spring in springs:
		spring.update(delta)
	"""
	for node in spring_nodes:
		if node.dynamic:
			node.velocity += wind * delta
	"""


func create_spring(a, b):
	if not a or not b:
		push_error("Invalid node for spring")
		return
	var spring := Spring.new(a, b, tightness, damp)
	springs.append(spring)
	pass

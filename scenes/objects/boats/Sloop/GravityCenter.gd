extends Position3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var rigid_body : RigidBody


# Called when the node enters the scene tree for the first time.
func _ready():
	
	rigid_body = _get_rigidbody_parent(self)
	
	if rigid_body:
		rigid_body.
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _get_rigidbody_parent(node : Node) -> Node:
	
	if not node:
		return null
	
	if node is RigidBody:
		return node
	
	return _get_rigidbody_parent(node.get_parent())

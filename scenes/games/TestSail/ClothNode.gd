extends MeshInstance


var spring_node : Spring.SpringNode
var velocity := Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	
	#set_as_toplevel(true)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if spring_node:
		self.velocity = spring_node.velocity
		self.global_transform.origin = spring_node.position

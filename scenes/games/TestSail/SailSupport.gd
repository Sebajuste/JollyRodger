extends Spatial


export(NodePath) var cloth_path
export var index := 0


onready var cloth = get_node(cloth_path)


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	
	if not cloth:
		set_physics_process(false)
		visible = false
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(_delta):
	
	var spring_node = cloth.spring_nodes[index]
	var t : Transform = cloth.global_transform * Transform(Basis(), spring_node.position) 
	self.global_transform.origin = t.origin
	


func get_spring_node() -> Spring.SpringNode:
	
	return cloth.spring_nodes[index]
	

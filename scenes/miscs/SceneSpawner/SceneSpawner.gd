class_name SceneSpawner
extends Spatial



# Called when the node enters the scene tree for the first time.
func _ready():
	
	Spawner.connect("on_node_emitted", self, "_on_node_emitted")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_node_emitted(node : Node):
	
	add_child(node)
	

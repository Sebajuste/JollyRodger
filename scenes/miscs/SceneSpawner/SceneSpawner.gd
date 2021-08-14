class_name SceneSpawner
extends Spatial



# Called when the node enters the scene tree for the first time.
func _ready():
	
	var _r := Spawner.connect("on_node_emitted", self, "_on_node_emitted")
	
	yield(get_tree(),"idle_frame")
	for node_ref in Spawner.instance_await:
		var node = node_ref.get_ref()
		if node:
			_on_node_emitted(node)
	
	Spawner.spawner_connected = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_node_emitted(node : Node):
	
	add_child(node)
	

extends Node


signal on_node_emitted(node)


var spawner_connected := false
var instance_await := []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func spawn(node):
	if spawner_connected:
		emit_signal("on_node_emitted", node)
	else:
		instance_await.append(weakref(node))

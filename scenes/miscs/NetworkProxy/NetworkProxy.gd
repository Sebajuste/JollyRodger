tool
extends Spatial


export(String) var client_path setget set_client_path
export(String) var server_path


var node


# Called when the node enters the scene tree for the first time.
func _ready():
	
	if not "--server" in OS.get_cmdline_args() or Engine.editor_hint:
		
		if not node or node.get_path() != client_path:
			
			load_node(client_path)
		
	if "--server" in OS.get_cmdline_args():
		
		load_node(server_path)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func load_node(path : String):
	if path == null:
		return
	if node != null:
		node.queue_free()
		node = null
	
	if ResourceLoader.exists(path):
		var scene = ResourceLoader.load(path)
		if scene:
			node = scene.instance()
			add_child(node)
		else:
			push_error("[%s] Cannot load : " % [ self.name, path])
	else:
		push_error("[%s] Cannot find : " % [ self.name, path])


func set_client_path(path):
	if path and path != client_path:
		client_path = path
		if  Engine.editor_hint:
			load_node(path)


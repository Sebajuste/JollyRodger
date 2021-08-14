tool
extends Spatial


export(String) var client_path setget set_client_path
export(String) var server_path




# Called when the node enters the scene tree for the first time.
func _ready():
	
	if not "--server" in OS.get_cmdline_args() or Engine.editor_hint:
		
		load_node(client_path)
		
	elif "--server" in OS.get_cmdline_args():
		
		load_node(server_path)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func load_node(path : String):
	if path == null:
		return
	for child in get_children():
		child.queue_free()
	var scene = load(path)
	if scene:
		var node = scene.instance()
		add_child(node)


func set_client_path(path):
	if path and path != client_path:
		client_path = path
		load_node(path)


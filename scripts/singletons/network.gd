extends Node

signal properties_created(id, properties)
signal properties_removed(id, properties)
signal property_changed(id, key, value)

signal kicked(cause)


class NodeSyncInfo extends Object:
	var path : String
	var filename : String
	var name : String
	var id : int
	var state : Dictionary
	
	func _init(_path : String, _filename : String, _name : String, _peer_id : int, _state : Dictionary):
		path = _path
		filename = _filename
		name = _name
		id = _peer_id
		state = _state
	



var Settings = {
	"Version": "",
	"Host": "",
	"Port": 12345,
	"MaxPlayer": 12,
	"SecurityKey": ""
}


var enabled := false
var is_server := false

var player_info : Dictionary = {}



var node_sync_list := []





# Called when the node enters the scene tree for the first time.
func _ready():
	var _r
	_r = get_tree().connect("network_peer_connected", self, "_player_connected")
	_r = get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	_r = get_tree().connect("connected_to_server", self, "_connected_ok")
	_r = get_tree().connect("connection_failed", self, "_connected_fail")
	_r = get_tree().connect("server_disconnected", self, "_server_disconnected")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if not node_sync_list.empty():
		
		for index in range(node_sync_list.size()-1, -1, -1):
			var node_sync_info: NodeSyncInfo = node_sync_list[index]
			
			#var parent = get_tree().get_root().get_node(node_sync_info.path)
			var parent := get_node(node_sync_info.path)
			
			if parent:
				var scene = load(node_sync_info.filename)
				var instance : Node = scene.instance()
				instance.name = node_sync_info.name
				instance.set_network_master( node_sync_info.id )
				parent.add_child(instance)
				
				for child in instance.get_children():
					if child.is_in_group("net_sync_node"):
						child.set_state(node_sync_info.state)
						break
				
				node_sync_list.remove(index)
				node_sync_info.free()
				
			else:
				push_error("Cannot found %s" % node_sync_info.path)


func is_peer_connected(peer_id : int):
	
	return true if player_info.has(peer_id) else false
	


func is_compatible_version(version_a : String, version_b : String) -> bool:
	
	var version_part_a := version_a.split(".")
	var version_part_b := version_b.split(".")
	
	if version_part_a[0] == version_part_b[0] and version_part_a[1] == version_part_b[1]:
		return true
	return false 


func close_connection():
	if enabled:
		get_tree().get_network_peer().close_connection()
		enabled = false
		player_info.clear()


func is_enabled() -> bool:
	return enabled


func set_property(key: String, value):
	
	rpc("rpc_set_property", key, value)
	


func has_property(peer_id: int, key: String) -> bool:
	if player_info.has(peer_id):
		var info = player_info[peer_id]
		return info.has(key)
	return false


func get_property(peer_id: int, key: String):
	if player_info.has(peer_id):
		var info = player_info[peer_id]
		if info.has(key):
			return info[key]
	return null


func erase_property(key: String):
	
	rpc("rpc_erase_property", key)
	


func get_self_peer_id() -> int:
	
	return get_tree().get_network_unique_id() if Network.enabled else 1
	


func broadcast(res: Node, method: String, args: Array):
	var self_peer_id = get_self_peer_id()
	for peer_id in player_info:
		if self_peer_id != peer_id:
			res.rpc(method, args)


func spawn_node(parent : Node, node: Node, state := {}):
	print("spawn_node ALL -> parent: ", parent.get_path(), ", name: ", node.name, ", filename: ", node.filename)
	if node.filename:
		rpc("rpc_spawn_node", parent.get_path(), node.name, node.filename, state)
	else:
		push_warning("Invalid node filemane for %s" % node.name )
	

func spawn_node_id(id: int, parent : Node, node: Node, state := {}):
	print("spawn_node [%d] -> parent: " % id, parent.get_path(), ", name: ", node.name, ", filename: ", node.filename)
	if node.filename:
		rpc_id(id, "rpc_spawn_node", parent.get_path(), node.name, node.filename, state)


func despawn_node(node: Node):
	
	rpc("rpc_despawn_node", node.get_path())
	


func rename_node(node: Node, old_name: String):
	
	rpc("rpc_rename_node", node.get_parent().get_path(), old_name, node.name)
	


func get_own_properties() -> Dictionary:
	var self_peer_id = get_self_peer_id()
	if not player_info.has(self_peer_id):
		player_info[self_peer_id] = {}
	return player_info[self_peer_id]


func get_self_property(key : String):
	var properties := get_own_properties()
	return properties[key]


func _player_connected(id: int):
	print("New player connected [id: %d]" % id)
	rpc_id(id, "rpc_register_player", get_own_properties() )
	


func _player_disconnected(id: int):
	print("Player disconnected [id: %d]" % id)
	if player_info.has(id):
		var info = player_info[id]
		var _r := player_info.erase(id)
		emit_signal("properties_removed", id, info)


func _connected_ok():
	enabled = true
	var _p := get_own_properties()
	pass


func _connected_fail():
	enabled = false
	player_info.clear()


func _server_disconnected():
	enabled = false
	player_info.clear()


func _check_version(id: int, key: String, value):
	if is_server and id != 1 and key == "game_version":
		var _p := get_own_properties()
		if not is_compatible_version(Settings.Version, value):
			print("Invalid game version")
			rpc_id(id, "rpc_kicked", "Invalid Game Version")
			get_tree().get_network_peer().disconnect_peer(id)
		else:
			print("Valid game version")


remotesync func rpc_register_player(properties):
	var id = get_tree().get_rpc_sender_id()
	player_info[id] = properties
	emit_signal("properties_created", id, properties)


remotesync func rpc_set_property(key: String, value):
	var id = get_tree().get_rpc_sender_id()
	var info
	if not player_info.has(id):
		info = {}
		player_info[id] = info
		emit_signal("properties_created", id, info)
	else:
		info = player_info[id]
	info[key] = value
	emit_signal("property_changed", id, key, value)
	_check_version(id, key, value)


remotesync func rpc_erase_property(key: String):
	var id = get_tree().get_rpc_sender_id()
	var info : Dictionary = player_info[id]
	var _r := info.erase(key)


remote func rpc_spawn_node(parent_path: String, name: String, filename: String, state : Dictionary):
	var peer_id = get_tree().get_rpc_sender_id()
	var node_sync_info := NodeSyncInfo.new(parent_path, filename, name, peer_id, state)
	node_sync_list.append(node_sync_info)


remote func rpc_despawn_node(node_path: String):
	var node = get_tree().get_root().get_node(node_path)
	if node:
		node.queue_free()


remote func rpc_rename_node(parent_path: String, old_name: String, name: String):
	var parent = get_tree().get_root().get_node(parent_path)
	var node = parent.get_node(old_name)
	node.set_name(name)


remote func rpc_kicked(cause : String):
	
	emit_signal("kicked", cause)
	

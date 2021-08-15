class_name NetSceneSync
extends Node



var scene : Node


# Called when the node enters the scene tree for the first time.
func _ready():
	
	scene = owner
	
	#get_tree().connect("network_peer_connected", self, "_player_connected")
	var _r := get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	# Request when scene is ready to receive all existings remote nodes
	rpc("rpc_request_sync_nodes", Network.get_self_peer_id() )
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


#
# Answer to a peer_id to spawn for him the owned node
#
remote func rpc_request_sync_nodes(id: int):
	var nodes : Array = get_tree().get_nodes_in_group("net_sync_node")
	for node in nodes:
		if scene.is_a_parent_of(node) and node.is_network_master() and node.replication_enabled:
			Network.spawn_node_id(id, node.sync_node.get_parent(), node.sync_node)

#
# Remove all node own by a peer_id
#
func _player_disconnected(id: int):
	var nodes = get_tree().get_nodes_in_group("net_sync_node")
	for sync_node in nodes:
		if scene.is_a_parent_of(sync_node) and sync_node.get_network_master() == id and sync_node.replication_enabled:
			sync_node.remove()
		else:
			sync_node.remove_peer(id)

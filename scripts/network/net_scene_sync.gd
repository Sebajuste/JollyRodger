class_name NetSceneSync
extends Node



var scene : Node


# Called when the node enters the scene tree for the first time.
func _ready():
	
	scene = owner
	
	var _r := get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	# Request when scene is ready to receive all existings remote nodes
	rpc("rpc_request_sync_nodes")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


#
# Answer to a peer_id to spawn for him the owned nodes
#
remote func rpc_request_sync_nodes():
	var peer_id = get_tree().get_rpc_sender_id()
	var nodes : Array = get_tree().get_nodes_in_group("net_sync_node")
	for node in nodes:
		if scene.is_a_parent_of(node) and node.is_network_master() and node.replication_enabled:
			Network.spawn_node_id(peer_id, node.sync_node.get_parent(), node.sync_node, node.get_state() )

#
# Remove all node own by a peer_id
#
func _player_disconnected(peer_id: int):
	var nodes = get_tree().get_nodes_in_group("net_sync_node")
	for sync_node in nodes:
		if scene.is_a_parent_of(sync_node): # If not is net managable
			if sync_node.get_network_master() == peer_id:# if the owner is disconnected
				if sync_node.replication_enabled: # remove if replication enabled
					sync_node.remove()
				else: # switch to server owner
					sync_node.sync_node.set_network_master( 1 )
			else: 
				# remove the disconnected client to the node peer list
				sync_node.remove_peer(peer_id)
			pass

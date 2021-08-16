tool
class_name NetNodeSync
extends Node


signal peer_added(peer_id)
signal peer_removed(peer_id)
signal master_changed(master_peer_id)
signal replication_done()

export var replication_enabled := true


var packet_id := 0
var last_packet_id_received := 0
var packet_delta := 0.0

# Emition list
var peers := []


# Jitter reception
var current_time := 0.0
var packet_time := 0.0


var sync_node : Node

var _last_name : String


static func update_float(from : float, to : float, threshold := 2.0) -> float:
	var diff := abs(to - from)
	if diff > threshold:
		return to
	elif diff > threshold / 2.0:
		return from + threshold / 2.0
	return from


static func update_vector3(from : Vector3, to: Vector3, threshold := 2.0) -> Vector3:
	var pos_diff : Vector3 = to - from
	var pos_length_squared := pos_diff.length_squared()
	if pos_length_squared > threshold*threshold:
		return to
	elif pos_length_squared > threshold:
		return from + pos_diff * threshold
	return from


static func update_quat(from : Quat, to :  Quat, threshold := 2.0) -> Quat:
	var quat_diff : Quat = to - from
	var quat_length_squared := quat_diff.length_squared()
	if quat_length_squared > threshold*threshold:
		return to
	elif quat_length_squared > threshold: 
		return from + quat_diff * threshold
	return from


static func update_transform(from : Transform, to : Transform, threshold := 2.0) -> Transform:
	var result := Transform()
	#result.basis = Basis( update_quat(Quat(from.basis), Quat(to.basis), threshold) )
	result.basis = to.basis
	result.origin = update_vector3(from.origin, to.origin, threshold)
	return result
	


func _init():
	
	add_to_group("net_sync_node")
	


# Called when the node enters the scene tree for the first time.
func _ready():
	sync_node = owner
	if Network.enabled and not is_network_master():
		rpc_id(get_network_master(), "rpc_request_sync")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	current_time += delta
	


func _enter_tree():
	sync_node = owner
	_last_name = sync_node.name
	if not Network.enabled:
		return
	if replication_enabled and is_network_master():
		Network.spawn_node(sync_node.get_parent(), sync_node, get_state() )
	var _r := sync_node.connect("renamed", self, "_node_renamed")


func _exit_tree():
	if Network.enabled and replication_enabled and is_network_master():
		Network.despawn_node(sync_node)
	if Network.enabled and replication_enabled and not is_network_master():
		var peer_id := get_network_master()
		if Network.is_peer_connected(peer_id):
			rpc_id(peer_id, "rpc_request_unsync")


func get_state() -> Dictionary:
	return {}


func set_state(_state : Dictionary):
	pass


func change_master(master_peer_id : int):
	if Network.enabled and is_network_master():
		if peers.find(master_peer_id) == -1:
			push_warning("Peer do not exists to be set as new master : %d" % master_peer_id)
			return
		rpc_id(master_peer_id, "rpc_set_master", peers, get_state())
		sync_node.set_network_master(master_peer_id)
		peers.clear()
		emit_signal("master_changed", master_peer_id)


func remove():
	
	sync_node.queue_free()
	


func remove_peer(peer_id : int):
	peers.erase(peer_id)
	emit_signal("peer_removed", peer_id)


master func rpc_request_sync():
	var peer_id = get_tree().get_rpc_sender_id()
	if not is_network_master():
		rpc_id(peer_id, "rpc_change_master", get_network_master(), [])
		return
	if not peers.has(peer_id):
		peers.append(peer_id)
		emit_signal("peer_added", peer_id)
		
		if peers.size() == Network.get_count_peers() - 1:
			emit_signal("replication_done")


master func rpc_request_unsync():
	var id = get_tree().get_rpc_sender_id()
	remove_peer(id)


puppet func rpc_set_master(_peers : Array, state : Dictionary):
	var old_master_id = get_tree().get_rpc_sender_id()
	if old_master_id != get_network_master():
		push_warning("Invald origin master. Is %d, expected %d" % [old_master_id, get_network_master()])
		return
	var master_peer_id := Network.get_self_peer_id()
	
	sync_node.set_network_master(master_peer_id)
	peers.append_array(_peers)
	peers.erase( master_peer_id )
	set_state(state)
	for peer_id in peers:
		rpc_id(peer_id, "rpc_change_master", master_peer_id)
	peers.append(old_master_id)
	emit_signal("master_changed", master_peer_id)


puppet func rpc_change_master(master_peer_id : int):
	var peer_id := get_tree().get_rpc_sender_id()
	if peer_id != master_peer_id:
		push_warning("Invald origin master. Id %d, expected %d" % [peer_id, master_peer_id])
		return
	sync_node.set_network_master(master_peer_id)
	
	rpc_id(master_peer_id, "rpc_request_sync")
	print("rpc_change_master, new : %d" % master_peer_id)
	
	emit_signal("master_changed", master_peer_id)


func _node_renamed():
	
	print("Old name : %s -> New name : %s" % [_last_name, sync_node.name])
	


func _get_configuration_warning() -> String:
	
	return "Invalid Node for network sync" if sync_node.filename == "" else ""
	

tool
class_name NetNodeSync
extends Node


export var enabled := true



var packet_id := 0
var last_packet_id_received := 0
var packet_delta := 0.0

# Jitter
var current_time := 0.0
var packet_time := 0.0


var sync_node : Node

var _last_name : String



static func update_vector3(from : Vector3, to: Vector3, threshold := 2.0) -> Vector3:
	var pos_diff : Vector3 = from - to
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
	result.basis = Basis( update_quat(Quat(from.basis), Quat(to.basis), threshold) )
	result.origin = update_vector3(from.origin, to.origin, threshold)
	return result
	


func _init():
	
	add_to_group("net_sync_node")
	


# Called when the node enters the scene tree for the first time.
func _ready():
	
	sync_node = owner
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	current_time += delta
	


func _enter_tree():
	sync_node = owner
	_last_name = sync_node.name
	if not Network.enabled:
		return
	if enabled and is_network_master():
		Network.spawn_node(sync_node.get_parent(), sync_node)
	sync_node.connect("renamed", self, "_node_renamed")


func _exit_tree():
	if Network.enabled and enabled and is_network_master():
		Network.despawn_node(sync_node)


func spawn(id: int):
	
	if enabled and is_network_master():
		Network.spawn_node_id(id, sync_node.get_parent(), sync_node)
	


func remove():
	
	sync_node.queue_free()
	


func _player_connected(id: int):
	if enabled and is_network_master():
		Network.spawn_node_id(id, sync_node.get_parent(), sync_node)


func _node_renamed():
	
	print("Old name : %s -> New name : %s" % [_last_name, sync_node.name])
	


func _get_configuration_warning() -> String:
	
	return "Invalid Node for network sync" if sync_node.filename == "" else ""
	

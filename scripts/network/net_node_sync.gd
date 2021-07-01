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
	

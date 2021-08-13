class_name DamageSource
extends Area


signal hit(hit_box)


export var damage := 1.0


var source


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _enter_tree():
	if Network.enabled and not is_network_master():
		rpc("rpc_request")


master func rpc_request():
	var peer_id := get_tree().get_rpc_sender_id()
	print("[Bullet] rpc_request : ", damage, ", ", source.get_path())
	rpc_id(peer_id, "rpc_request_response", damage, source.get_path())
	pass


puppet func rpc_request_response(_damage : float, source_path : String):
	print("[Bullet] rpc_request_response : ", _damage, ", ", source_path)
	damage = damage
	source = get_node(source_path)

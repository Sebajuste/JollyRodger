class_name DamageSource
extends Area


signal hit(hit_box)


export var damage := 1


var source : Node
var hit_list := []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _enter_tree():
	if Network.enabled and not is_network_master():
		rpc("rpc_request")


func hitbox_hit(hit_box) -> bool:
	if not hit_list.has(hit_box):
		hit_list.append(hit_box)
		emit_signal("hit", hit_box)
		return true
	return false


master func rpc_request():
	var peer_id := get_tree().get_rpc_sender_id()
	
	var source_path := ""
	
	if source:
		source_path = source.get_path()
	else:
		push_warning("[%s] Invalid source to get his path" % self.name)
	print("[Bullet] rpc_request : ", damage, ", ", source_path)
	rpc_id(peer_id, "rpc_request_response", damage, source_path)
	pass


puppet func rpc_request_response(_damage : float, source_path : String):
	print("[Bullet] rpc_request_response : ", _damage, ", ", source_path)
	damage = damage
	if source_path and source_path != "":
		source = get_node(source_path)


func _on_ClearTimer_timeout():
	
	hit_list.clear()
	

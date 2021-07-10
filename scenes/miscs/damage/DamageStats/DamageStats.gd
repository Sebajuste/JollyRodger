class_name DamageStats
extends Node


signal damage_taken(damage)
signal heal_received(heal)
signal health_changed(new_value, old_value)
signal health_depleted()
signal health_undepleted()


export var max_health: int = 10 setget set_max_health


var health: int = 0 setget set_health
var alive := true


# Called when the node enters the scene tree for the first time.
func _ready():
	
	health = max_health
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func is_alive() -> bool:
	
	return health > 0
	


func revive(value):
	if is_alive():
		return
	if not Network.enabled or is_network_master():
		set_health(value)
	else:
		rpc("rpc_heal", value)


func heal(value):
	if not is_alive():
		return
	var new_health = health + value
	if not Network.enabled or is_network_master():
		set_health(new_health)
	else:
		rpc("rpc_heal", new_health)


func take_damage(hit: Hit, hit_box = null) -> void:
	if not is_alive():
		return
	
	var new_health = health - hit.damage
	print("[%s] take damage : " % owner.name, new_health)
	set_health(new_health)


func set_max_health(value: int) -> void:
	if value == null:
		return
	max_health = max(1, value)


func set_health(value: int):
	value = clamp(value, 0, max_health)
	if Network.enabled:
		if is_network_master():
			rpc("rpc_set_health", value)
			rpc_set_health(value)
	else:
		rpc_set_health(value)


master func rpc_heal(value):
	if health < value:
		set_health(value)


puppet func rpc_set_health(value: int):
	var old_health = health
	health = clamp(value, 0, max_health)
	if old_health > health:
		emit_signal("damage_taken", old_health - health)
	else:
		emit_signal("heal_received", health - old_health)
	emit_signal("health_changed", health, old_health)
	if health == 0:
		alive = false
		emit_signal("health_depleted")
	elif old_health == 0:
		alive = true
		emit_signal("health_undepleted")

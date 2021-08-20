extends Spatial


export(String, "None", "GB", "Spain", "Pirate") var faction
export var invincible := false setget set_invincible

onready var cannon := $Cannon
onready var search_await_timer : Timer = $SearchAwaitTimer
onready var capturable := $Capturable
onready var damage_stats := $DamageStats


var ships := []

var target_ref := weakref(null)
var ready_to_target := true


# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	capturable.faction = faction
	
	set_invincible(invincible)
	damage_stats.invincible = invincible
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if Network.enabled and not is_network_master():
		return
	
	if not damage_stats.is_alive():
		return
	
	var target = target_ref.get_ref()
	if target == null and ready_to_target and not ships.empty():
		var t = get_nearest_target()
		if t != null:
			target = t
			search_await_timer.start()
			ready_to_target = false
	
	if target and cannon.fire_ready:
		
		cannon.fire(target.global_transform.origin, target.linear_velocity)
		


func _physics_process(_delta):
	
	if not damage_stats.is_alive():
		return
	
	var target = target_ref.get_ref()
	if target:
		cannon.look_at(
			target.global_transform.origin,
			Vector3.UP
		)


func get_nearest_target() -> Spatial:
	
	var near_target = null
	var near_distance_squared = null
	
	for ship in ships:
		
		if ship.flag.faction != capturable.faction and ship.alive:
			
			var distance_squared := self.global_transform.origin.distance_squared_to(ship.global_transform.origin)
			
			if near_target == null or near_distance_squared > distance_squared:
				near_target = ship
				near_distance_squared = distance_squared
	
	return near_target


func set_invincible(value):
	if is_inside_tree() and (not Network.enabled or is_network_master() ):
		invincible = value
		if damage_stats:
			damage_stats.invincible = invincible


func _on_DetectionArea_body_entered(body):
	if body.is_in_group("ship"):
		ships.append(body)


func _on_DetectionArea_body_exited(body):
	if body.is_in_group("ship"):
		var index = ships.find(body)
		if index != -1:
			ships.remove(index)


func _on_SearchAwaitTimer_timeout():
	
	ready_to_target = true
	


func _on_DamageStats_health_depleted():
	
	$Smoke.visible = true
	$Smoke.emitting = true
	


func _on_DamageStats_health_undepleted():
	
	$Smoke.emitting = false
	


func _on_Capturable_uncontested():
	
	if Network.enabled and not is_network_master():
		return
	
	if not damage_stats.is_alive():
		damage_stats.revive( damage_stats.max_health )
	else:
		damage_stats.heal( damage_stats.max_health )
	

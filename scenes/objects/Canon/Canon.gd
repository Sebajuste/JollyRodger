extends Spatial


var BULLET_SCENE = preload("res://scenes/objects/Bullet/Bullet.tscn")


export var speed := 50.0
export var fire_rate : int = 6 setget set_fire_rate
export var fire_delay := 0.0 setget set_fire_delay


onready var muzzle = $Skin/Muzzle


var max_range : float = 0.0
var fire_ready := true


var proj_velocity : Vector3 = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	
	self.max_range = Balistic.max_range(speed, 9.8, 0.0)
	
	set_fire_rate(fire_rate)
	set_fire_delay(fire_delay)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func is_in_range(target_position : Vector3, target_velocity := Vector3.ZERO) -> bool:
	
	var target_dir := (self.global_transform.origin - target_position).normalized()
	
	if target_dir.dot( self.global_transform.basis.z ) < 0.8:
		return false
	
	if self.global_transform.origin.distance_squared_to(target_position) < max_range * max_range:
		return true
	
	return false
	


func fire(target_position : Vector3, target_velocity := Vector3.ZERO) -> bool:
	
	if not fire_ready:
		return false
	
	fire_ready = false
	$ReloadTimer.start()
	
	proj_velocity = Balistic.solve_ballistic_arc_velocity(
		muzzle.global_transform.origin,
		speed,
		target_position,
		target_velocity
	)
	
	if Vector3.ZERO.is_equal_approx(proj_velocity):
		print("no fire solution found")
		return false
	
	
	proj_velocity += Vector3(
				rand_range(-0.5, 0.5),
				rand_range(-0.5, 0.5),
				rand_range(-0.5, 0.5)
			)
	
	if fire_delay > 0.0:
		$FireDelay.start()
	else:
		_on_fire_delayed()
	
	return true


func _on_fire_delayed():
	
	if Vector3.ZERO.is_equal_approx(proj_velocity):
		print("no fire solution found")
		return false
	
	var bullet : RigidBody = BULLET_SCENE.instance()
	var peer_id := Network.get_self_peer_id()
	bullet.set_network_master( peer_id )
	bullet.name = "%s_%d_%d" % [bullet.name, peer_id, randi()]
	#var root = get_tree().get_root().get_child(0)
	
	Spawner.emit_signal("on_node_emitted", bullet)
	#root.add_child(bullet)
	
	bullet.global_transform.origin = muzzle.global_transform.origin
	bullet.apply_central_impulse(proj_velocity)
	
	if Network.enabled:
		rpc("rpc_fire")
	else:
		rpc_fire()
	
	


func set_fire_rate(value):
	fire_rate = value
	$ReloadTimer.wait_time = 60.0 / fire_rate


func set_fire_delay(value):
	fire_delay = value
	if fire_delay > 0.0:
		$FireDelay.wait_time = fire_delay


func _on_ReloadTimer_timeout():
	
	fire_ready = true
	


remotesync func rpc_fire():
	
	$FireSound.pitch_scale = rand_range(0.8, 1.2)
	$FireSound.play()
	
	pass

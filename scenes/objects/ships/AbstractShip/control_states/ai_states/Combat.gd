extends ShipState


signal target(target)
signal untarget(target)


class Ennemy:
	
	var ship : AbstractShip
	var target_ref : WeakRef
	var danger_score : float
	
	func _init(_ship : AbstractShip, _target : AbstractShip):
		ship = _ship
		target_ref = weakref(_target)
		danger_score = 0
	
	func update_score():
		
		var max_target_range := 70
		var max_target_range_squared := max_target_range*max_target_range
		
		var target : AbstractShip = target_ref.get_ref()
		
		if not target:
			danger_score = 0
			return
		
		var target_dst_squared := ship.global_transform.origin.distance_squared_to(target.global_transform.origin)
		
		var dst_score : float = max( (max_target_range_squared - target_dst_squared) / max_target_range_squared, 0)
		var healt_score : float = 1 - (target.damage_stats.health / target.damage_stats.max_health)
		danger_score = (dst_score + healt_score) / 2



export(Resource) var boid_ennemy_config
export(Resource) var boid_ally_config


var ai_state


var targets_engaged := []
var current_target_ref := weakref(null)


# Called when the node enters the scene tree for the first time.
func _ready():
	
	ai_state = _state_machine.get_parent()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func enter(msg := {}):
	if msg.has("target_object"):
		var ennemy := Ennemy.new(ship, msg.target_object)
		targets_engaged.append(ennemy)


func exit():
	
	set_target(null)
	

func process(delta):
	
	var ennemies_ship : Array = ship.detection_area.get_ennemies()
	
	# clean invalid or to far away targets
	var max_range : float = ship.cannons.get_max_range()
	var max_range_squared := max_range*max_range
	for index in range(targets_engaged.size()-1, -1, -1):
		var ennemy : Ennemy = targets_engaged[index]
		var target : Spatial = ennemy.target_ref.get_ref()
		if target and target.alive:
			var position_delta_squared := target.global_transform.origin.distance_squared_to(ship.global_transform.origin)
			if position_delta_squared > max_range_squared:
				targets_engaged.remove(index)
		else:
			targets_engaged.remove(index)
	
	# Quit Combat mode if not target are available
	if targets_engaged.empty() and ennemies_ship.empty():
		_state_machine.transition_to("AvoidObstacle/Idle")
		return
	
	var ennemies := []
	for ennemy_ship in ennemies_ship:
		var ennemy := Ennemy.new(ship, ennemy_ship)
		ennemies.append(ennemy)
	
	
	#
	# Target control
	#
	
	# Calculate ennemy scoring
	ennemies.append_array(targets_engaged)
	for ennemy in ennemies:
		ennemy.update_score()
	ennemies.sort_custom(Ennemy, "sort")
	
	# Select current target
	if not ennemies.empty():
		set_target(ennemies[0].target_ref.get_ref())
	else:
		set_target(null)
	
	
	#
	# Target fire
	#
	var current_target = current_target_ref.get_ref()
	if current_target and ship.cannons.is_fire_ready():
		if current_target is RigidBody:
			ship.cannons.fire(current_target.global_transform.origin, current_target.linear_velocity)
		else:
			ship.cannons.fire(current_target.global_transform.origin)
	
	_parent.process(delta)
	


func physics_process(delta):
	
	var boid_self := Boid3D.new(ship.linear_velocity, ship.global_transform.origin)
	
	var ennemy_boids := Array()
	for ennemy_ship in ship.detection_area.get_ennemies():
		ennemy_boids.append( Boid3D.new(ennemy_ship.linear_velocity, ennemy_ship.global_transform.origin) )
	
	# TODO : add target_engaged if not already present in ennemy_boids
	
	var allies_boids := Array()
	for ally_ship in ship.detection_area.get_allies():
		allies_boids.append( Boid3D.new(ally_ship.linear_velocity, ally_ship.global_transform.origin) )
	
	var boids := Array()
	boids.append_array(ennemy_boids)
	boids.append_array(allies_boids)
	
	
	var ennemy_move := boid_self.calculate_move_direction(ennemy_boids, self.boid_ennemy_config)
	
	var ally_move := boid_self.calculate_move_direction(allies_boids, self.boid_ally_config)
	
	_parent.chosen_direction = ennemy_move + ally_move
	
	var current_target : Spatial = current_target_ref.get_ref()
	if current_target:
		var target_delta := current_target.global_transform.origin - ship.global_transform.origin
		if target_delta.length_squared() > boid_ennemy_config.cohesion_distance*boid_ennemy_config.cohesion_distance:
			_parent.chosen_direction += target_delta.normalized() * 0.25
	
	_parent.chosen_direction = _parent.chosen_direction.normalized()
	
	_parent.physics_process(delta)
	
	boid_self.free()
	for ennemy in ennemy_boids:
		ennemy.free()
	for ally in allies_boids:
		ally.free()


func set_target(value):
	if value:
		if current_target_ref.get_ref() != value:
			current_target_ref = weakref(value)
			emit_signal("target", value)
	else:
		var old_target = current_target_ref.get_ref()
		current_target_ref = weakref(null)
		emit_signal("untarget", old_target)

extends ShipState


export var num_rays := 30
export var look_ahead := 20

#var global_goal_position := Vector3.ZERO


var path_position := Vector3.ZERO
var path_direction := Vector3.ZERO

var chosen_direction := Vector3.ZERO

var nearest_collision := false
var nearest_collision_distance := 0.0

var ray_directions := []
var interest := []
var danger := []

var rays := []


var danger_rays := []


# Called when the node enters the scene tree for the first time.
func _ready():
	ray_directions.resize(num_rays)
	interest.resize(num_rays)
	danger.resize(num_rays)
	rays.resize(num_rays)
	danger_rays.resize(num_rays)
	for i in range(num_rays):
		var angle := 0.0
		if i % 2:
			angle = (i) * (PI * 2 / num_rays)
		else:
			angle = (-i-1) * (PI * 2 / num_rays)
		ray_directions[i] = Vector3.FORWARD.rotated(Vector3.UP, angle + (PI * 2 / num_rays) )
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func enter(_msg : Dictionary = {}):
	
	print("AI enable")
	pass


func exit():
	
	print("AI disable")
	


func process(delta):
	
	if path_position.is_equal_approx(Vector3.ZERO):
		path_position = ship.global_transform.origin + -ship.global_transform.basis.z * 100 + Vector3(-50, 0, 500)
	
	
	var path_position_delta = path_position - ship.global_transform.origin
	path_direction = path_position_delta.normalized()
	
	# Need to move to goal position
	if path_position_delta.length_squared() > 10.0*10.0:
		
		if nearest_collision:
			
			var v := ship.linear_velocity.length_squared()
			
			var s := look_ahead*look_ahead * nearest_collision_distance
			var t := s / v
			
			ship.sail_position = lerp(ship.sail_position, 1.0 / t + 1.0/v, delta)
		else:
			ship.sail_position = lerp(ship.sail_position, 1.0, delta)
	else:
		ship.sail_position = lerp(ship.sail_position, 0.0, delta)
	
	
	
	# Need to change direction
	var p := (-ship.global_transform.basis.z).rotated(Vector3.UP, PI/2)
	var dot := p.dot(chosen_direction)
	
	
	if dot > 0.1:
		ship.rudder_position = lerp(ship.rudder_position, -1.0, delta)
	elif dot < -0.1:
		ship.rudder_position = lerp(ship.rudder_position, 1.0, delta)
	else:
		ship.rudder_position = lerp(ship.rudder_position, 0.0, delta)
	
	pass

func physics_process(delta):
	
	#set_interest()
	#set_danger()
	#choose_direction()
	
	find_unobstructed_direction()
	


func set_interest():
	
	var angle : float = Vector3.FORWARD.angle_to(-ship.global_transform.basis.z)
	
	if Vector3.RIGHT.dot(-ship.global_transform.basis.z) > 0.0:
		angle = 2*PI - angle
	
	for i in num_rays:
		var ray : Vector3 = ray_directions[i].rotated(Vector3.UP, angle)
		var d = ray.dot(path_direction)
		interest[i] = max(0, d)
		rays[i] = ray


func set_danger():
	var space_state : PhysicsDirectSpaceState = ship.get_world().direct_space_state
	for i in num_rays:
		var result := space_state.intersect_ray(
			ship.global_transform.origin,
			ship.global_transform.origin + rays[i] * look_ahead,
			[ship]
		)
		danger[i] = 1.0 if result else 0.0
		danger_rays[i] = rays[i] if result else Vector3.ZERO


func choose_direction():
	
	chosen_direction = Vector3.ZERO
	
	var danger_found := false
	
	for i in range(num_rays):
		if danger[i] > 0.0:
			interest[i] = 0.0
			danger_found = true
		elif danger_found:
			chosen_direction = rays[i].normalized()
			return
		else:
			chosen_direction = path_direction.normalized()
			return
		chosen_direction += rays[i] * interest[i]
		
	
	chosen_direction = chosen_direction.normalized()
	
	pass


func find_unobstructed_direction():
	var space_state : PhysicsDirectSpaceState = ship.get_world().direct_space_state
	
	var angle : float = Vector3.FORWARD.angle_to(-ship.global_transform.basis.z)
	if Vector3.RIGHT.dot(-ship.global_transform.basis.z) > 0.0:
		angle = 2*PI - angle
	
	for i in range(num_rays):
		rays[i] = Vector3.ZERO
		danger_rays[i] = Vector3.ZERO
	
	var speed := ship.linear_velocity.length()
	
	nearest_collision = false
	nearest_collision_distance = 0.0
	
	for i in range(num_rays):
		
		var ray : Vector3 = ray_directions[i].rotated(Vector3.UP, angle)
		
		var result := space_state.intersect_ray(
			ship.global_transform.origin,
			ship.global_transform.origin + ray * max(look_ahead, look_ahead*speed),
			[ship]
		)
		
		
		rays[i] = ray * speed
		
		if result:
			var dist_collision := ship.global_transform.origin.distance_squared_to(result.position)
			if not nearest_collision:
				nearest_collision_distance = dist_collision
			else:
				if dist_collision < nearest_collision_distance:
					nearest_collision_distance = dist_collision
			nearest_collision = true
			danger_rays[i] = ray
		elif nearest_collision:
			chosen_direction = ray.normalized()
			return
		else:
			chosen_direction = path_direction.normalized()
			return
		
	
	

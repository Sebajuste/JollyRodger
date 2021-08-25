extends ShipState


const NUM_RAYS := 9


export var look_ahead := 10


var move_direction := Vector3.ZERO
var chosen_direction := Vector3.ZERO

var nearest_collision := false
var nearest_collision_distance := 0.0

var max_sail := 1.0

var ray_directions := []
var interest := []
var danger := []

var rays := []
var danger_rays := []



# Called when the node enters the scene tree for the first time.
func _ready():
	ray_directions.resize(NUM_RAYS)
	interest.resize(NUM_RAYS)
	danger.resize(NUM_RAYS)
	rays.resize(NUM_RAYS)
	danger_rays.resize(NUM_RAYS)
	for i in range(NUM_RAYS):
		var angle := 0.0
		if i % 2:
			angle = (i) * (PI * 2 / NUM_RAYS)
		else:
			angle = (-i-1) * (PI * 2 / NUM_RAYS)
		ray_directions[i] = Vector3.FORWARD.rotated(Vector3.UP, angle + (PI * 2 / NUM_RAYS) )




func process(delta):
	
	if Vector3.ZERO.is_equal_approx(chosen_direction):
		ship.sail_position = lerp(ship.sail_position, 0.0, delta)
		ship.rudder_position = lerp(ship.rudder_position, 0.0, delta)
		return
	
	var forward := true if chosen_direction.dot(-ship.global_transform.basis.z) > 0 else false
	
	var local_max_sail := max_sail if forward else 0.5
	
	# If the ship is near of obstacles
	if nearest_collision:
		var s := look_ahead*200
		var t = 1 - ( s - nearest_collision_distance ) / s
		ship.sail_position = lerp(ship.sail_position, clamp(t, 0.1, local_max_sail), delta)
	elif not chosen_direction.is_equal_approx(Vector3.ZERO):
		ship.sail_position = lerp(ship.sail_position, local_max_sail, delta)
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
		ship.rudder_position = lerp(ship.rudder_position, -dot, delta)
	
	pass


func physics_process(_delta):
	
	find_unobstructed_direction()
	


func find_unobstructed_direction():
	
	# var space_state : PhysicsDirectSpaceState = ship.get_world().direct_space_state
	
	var speed := ship.linear_velocity.length()
	var ray_look_ahead := max(look_ahead, look_ahead*speed)
	
	var move_forward := true if not chosen_direction or chosen_direction.is_equal_approx(Vector3.ZERO) else false
	
	var angle : float = Vector3.FORWARD.angle_to(-ship.global_transform.basis.z)
	if Vector3.RIGHT.dot(-ship.global_transform.basis.z) > 0.0:
		angle = 2*PI - angle
	
	var next_choosen_dir := Vector3.ZERO
	
	
	nearest_collision = false
	nearest_collision_distance = 0.0
	
	
	for i in range(NUM_RAYS):
		
		var ray : Vector3 = ray_directions[i].rotated(Vector3.UP, angle)
		rays[i] = ray
		
		
		# Test danger
		var _r := ray_detection(i, ray, ray_look_ahead)
		
		
		# Set Interest
		if danger_rays[i]:
			interest[i] = 0
		else:
			if move_forward:
				interest[i] = max(0, rays[i].dot(-ship.global_transform.basis.z) )
			else:
				interest[i] = max(0, rays[i].dot(chosen_direction) )
		
		next_choosen_dir += rays[i] * interest[i]
		
	
	chosen_direction = next_choosen_dir.normalized()
	
	pass


func find_unobstructed_direction_old():
	#var space_state : PhysicsDirectSpaceState = ship.get_world().direct_space_state
	
	var angle : float = Vector3.FORWARD.angle_to(-ship.global_transform.basis.z)
	if Vector3.RIGHT.dot(-ship.global_transform.basis.z) > 0.0:
		angle = 2*PI - angle
	
	for i in range(NUM_RAYS):
		rays[i] = Vector3.ZERO
		#danger_rays[i] = Vector3.ZERO
	
	var speed := ship.linear_velocity.length()
	
	var ray_look_ahead := max(look_ahead, look_ahead*speed)
	
	nearest_collision = false
	nearest_collision_distance = 0.0
	
	
	# Check all dangers
	for i in range(NUM_RAYS):
		if danger_rays[i]:
			var ray : Vector3 = ray_directions[i].rotated(Vector3.UP, angle)
			
			var _r := ray_detection(i, ray, ray_look_ahead)
	
	
	# Check all rays
	for i in range(NUM_RAYS):
		
		if danger_rays[i]:
			continue
		
		var ray : Vector3 = ray_directions[i].rotated(Vector3.UP, angle)
		
		rays[i] = ray * speed
		
		var obstacle_detected := ray_detection(i, ray, ray_look_ahead)
		
		if obstacle_detected:
			if i < NUM_RAYS - 1:
				ray = ray_directions[i+1].rotated(Vector3.UP, angle)
				var _r := ray_detection(i+1, ray, ray_look_ahead)
				rays[i+1] = ray * speed
		elif nearest_collision:
			chosen_direction = (danger_avoidance()).normalized()
			if i < NUM_RAYS - 1:
				ray = ray_directions[i+1].rotated(Vector3.UP, angle)
				var _r := ray_detection(i+1, ray, ray_look_ahead)
				rays[i+1] = ray * speed
			break
		"""
		else:
			chosen_direction = move_direction.normalized()
			break
		"""


func danger_avoidance() -> Vector3:
	
	var count := 0
	var steer := Vector3.ZERO
	
	for i in range(NUM_RAYS):
		if danger_rays[i]:
			var delta_position : Vector3 = ship.global_transform.origin - danger_rays[i]
			steer += delta_position.normalized() / delta_position.length()
			count += 1
	
	if count > 0:
		steer = steer / count
		return steer.normalized()
	
	return Vector3.ZERO


func ray_detection(idx : int, ray : Vector3, ray_look_ahead : float) -> bool:
	
	var space_state : PhysicsDirectSpaceState = ship.get_world().direct_space_state
	
	var result := space_state.intersect_ray(
		ship.global_transform.origin + Vector3.DOWN*2,
		ship.global_transform.origin + Vector3.DOWN*2 + ray * ray_look_ahead,
		[ship]
	)
	
	if result:
		var dist_collision := ship.global_transform.origin.distance_squared_to(result.position)
		if not nearest_collision:
			nearest_collision_distance = dist_collision
		else:
			if dist_collision < nearest_collision_distance:
				nearest_collision_distance = dist_collision
		nearest_collision = true
		danger_rays[idx] = ray #result.position - ship.global_transform.origin
		return true
	else:
		danger_rays[idx] = null
		return false


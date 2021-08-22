extends RigidBody


var WATER_SPLASH_SCENE = preload("res://scenes/miscs/WaterSplash/WaterSplash.tscn")


onready var damage_source := $DamageSource


export var drag_coef := 0.2


var submerded := false


# Called when the node enters the scene tree for the first time.
func _ready():
	
	if not Network.enabled or is_network_master():
		$LifeTimer.start()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if global_transform.origin.y < -10:
		queue_free()
	
	pass


func _physics_process(delta : float):
	
	if not is_inside_tree():
		return
	
	var volumic_mass := 1.0
	
	for water_mesh in get_tree().get_nodes_in_group("water_mesh"):
		
		var wave_height : float = water_mesh.get_wave_height( self.global_transform.origin )
		
		if wave_height > self.global_transform.origin.y:
			
			volumic_mass = water_mesh.volumic_mass
			
			if not submerded:
				var water_splash : Spatial = WATER_SPLASH_SCENE.instance()
				water_splash.transform.origin = self.global_transform.origin
				
				Spawner.spawn(water_splash)
				
				# TODO : ricochet
			
			submerded = true
			break
		#else:
		#	submerded = false
	
	if submerded:
		
		var speed_squared := linear_velocity.length_squared()
		
		var f := 1.0/2.0 * volumic_mass * drag_coef * speed_squared
		
		var move_dir := linear_velocity.normalized()
		
		var resistance_force := Vector3(
			-move_dir.x,
			-move_dir.y,
			-move_dir.z
		) * f * delta
		
		add_central_force(resistance_force)
	


func _integrate_forces(state : PhysicsDirectBodyState):
	
	$NetSyncBullet.integrate_forces(state)
	


func _on_LifeTimer_timeout():
	
	queue_free()
	


func _on_DamageSource_hit(_hit_box):
	
	queue_free()
	

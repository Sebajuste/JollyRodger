extends RigidBody

var WATER_SPLASH_SCENE = preload("res://scenes/miscs/WaterSplash/WaterSplash.tscn")


onready var damage_source := $DamageSource


var submerded := false


# Called when the node enters the scene tree for the first time.
func _ready():
	
	if is_network_master():
		$LifeTimer.start()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(delta):
	
	if not is_inside_tree():
		return
	
	var colliding_bodies := get_colliding_bodies()
	
	for water_mesh in get_tree().get_nodes_in_group("water_mesh"):
		
		var wave_height : float = water_mesh.get_wave_height( self.global_transform.origin )
		
		if wave_height > self.global_transform.origin.y:
			
			if not submerded:
				var water_splash : Spatial = WATER_SPLASH_SCENE.instance()
				water_splash.transform.origin = self.global_transform.origin
				#get_parent().add_child(water_splash)
				
				Spawner.spawn(water_splash)
				
				# TODO : ricochet
				
			
			submerded = true
		else:
			submerded = false
	
	
	if colliding_bodies.size() > 0:
		self.visible = false
		queue_free()
		pass


func _integrate_forces(state : PhysicsDirectBodyState):
	
	$NetSyncBullet.integrate_forces(state)
	


func _on_LifeTimer_timeout():
	
	queue_free()
	


func _on_DamageSource_hit(hit_box):
	
	queue_free()
	

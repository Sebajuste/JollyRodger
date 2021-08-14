extends Spatial


export var wave_margin := 1.0



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(_delta):
	
	var water_meshs := get_tree().get_nodes_in_group("water_mesh")
	
	if not water_meshs.empty():
		var water_mesh = water_meshs[0]
		
		var wave_height : float = water_mesh.get_wave_height(self.global_transform.origin) + wave_margin
		
		if wave_height > self.global_transform.origin.y:
			self.global_transform.origin.y = wave_height
			pass
		
		
	
	
	
	

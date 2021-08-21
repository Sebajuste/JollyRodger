extends Spatial


export(OpenSimplexNoise) var noise : OpenSimplexNoise


onready var ship := $SwedishRoyalYachtAmadis


var offset := 0.0


var wind := Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	#$Cloth/ClothNode.other = $Cloth/ClothNode2
	#$Cloth/ClothNode2.other = $Cloth/ClothNode
	
	
	$DebugOverlay.vector.add_vector(self, "wind", 1.0, 2.0, Color.blue)
	
	"""
	$DebugOverlay.vector.add_vector($Cloth/ClothNode, "velocity", 1.0, 2.0, Color.green)
	$DebugOverlay.vector.add_vector($Cloth/ClothNode2, "velocity", 1.0, 2.0, Color.green)
	$DebugOverlay.vector.add_vector($Cloth/ClothNode3, "velocity", 1.0, 2.0, Color.green)
	"""
	
	"""
	for node in $Cloth/Debug.get_children():
		$DebugOverlay.vector.add_vector(node, "velocity", 1.0, 2.0, Color.green)
	
	$DebugOverlay.stats.add_property($Cloth/Debug.get_child(7), "velocity")
	
	
	for node in $Spring/Debug.get_children():
		$DebugOverlay.vector.add_vector(node, "velocity", 1.0, 2.0, Color.green)
	
	$DebugOverlay.stats.add_property($Spring/Debug.get_child(1), "velocity")
	$DebugOverlay.stats.add_property($Spring/Debug.get_child(1), "global_transform:origin")
	"""
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	offset += delta * 100
	
	wind = Vector3(
		0.0, 
		0.0,
		-(noise.get_noise_1d(offset) + 1) / 2.0
	) * 30
	
	ship.get_node("Pivot/Cloth").wind = wind


func _physics_process(delta):
	
	if Input.is_action_pressed("sail_right"):
		if ship.get_node("Pivot").transform.basis.get_euler().y > -1.0:
			ship.get_node("Pivot").transform = ship.get_node("Pivot").transform.rotated(Vector3.UP, -delta)
	
	if Input.is_action_pressed("sail_left"):
		if ship.get_node("Pivot").transform.basis.get_euler().y < 1.0:
			ship.get_node("Pivot").transform = ship.get_node("Pivot").transform.rotated(Vector3.UP, delta)
		
	
	


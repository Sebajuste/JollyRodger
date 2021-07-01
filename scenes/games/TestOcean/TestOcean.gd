tool
extends Spatial


onready var ocean := $Ocean
onready var cube := $Cube


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# $RigidBody/Floater.water_manager = $Ocean
	
	# $Ocean.ocean_time = 12345.56
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(delta):
	
	if cube and ocean:
		cube.global_transform.origin.y = ocean.get_wave_height( cube.global_transform.origin )
	

extends VBoxContainer


export(NodePath) var boat_path 


onready var boat : RigidBody = get_node(boat_path)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if not boat:
		return
	
	$Position/Value.text = str( "x: %d, y: %d, z: %d" % [
		boat.global_transform.origin.x,
		boat.global_transform.origin.y,
		boat.global_transform.origin.z
	] )
	
	var dir := Vector2(boat.global_transform.basis.z.x, boat.global_transform.basis.z.z)
	var angle := rad2deg( dir.angle() )
	if angle < 0:
		angle = 360 - abs(angle)
	$Direction/Value.text = str( angle )
	
	
	$Speed/Value.text = str( boat.linear_velocity.length() )
	
#	pass

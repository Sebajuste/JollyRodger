extends CameraRigState


var offset_y := 10.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func enter(_msg: Dictionary = {}):
	
	camera_rig.set_as_toplevel(true)
	pass


func physics_process(delta):
	
	_parent.physics_process(delta)
	
	var target : Spatial = camera_rig.target
	if target:
		var offset : Vector3 = camera_rig.global_transform.origin - target.global_transform.origin
		
		offset = offset.normalized() * camera_rig.distance
		offset.y = target.global_transform.origin.y + offset_y
		
		camera_rig.look_at_from_position(
			target.global_transform.origin + offset,
			target.global_transform.origin,
			Vector3.UP
		)
	
	pass

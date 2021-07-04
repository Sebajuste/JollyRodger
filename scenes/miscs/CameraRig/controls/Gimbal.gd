extends CameraRigState


const ANGLE_X_MIN: = -PI/4
const ANGLE_X_MAX: =  PI/3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	
	if _parent._input_relative.length_squared() > 0:
		camera_rig.rotate_object_local(Vector3.UP, -_parent._input_relative.x * camera_rig.rotation_speed * delta)
		camera_rig.pivot.rotate_object_local(Vector3.LEFT, _parent._input_relative.y * camera_rig.rotation_speed * delta)
		_parent._input_relative = Vector2.ZERO
	
	camera_rig.rotation.x = 0
	camera_rig.rotation.z = 0
	
	camera_rig.pivot.rotation.x = clamp(camera_rig.pivot.rotation.x, ANGLE_X_MIN, ANGLE_X_MAX) #1.4, -0.01
	camera_rig.pivot.rotation.y = 0
	camera_rig.pivot.rotation.z = 0
	


func physics_process(delta):
	if camera_rig.target:
		camera_rig.global_transform.origin = camera_rig.target.global_transform.origin



func _input(event : InputEvent):
	
	_parent.input(event)
	



func unhandled_input(event):
	
	_parent.unhandled_input(event)
	
	if event.is_action_pressed("move_camera"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_parent.move_camera = true
	
	if event.is_action_released("move_camera"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_parent.move_camera = false

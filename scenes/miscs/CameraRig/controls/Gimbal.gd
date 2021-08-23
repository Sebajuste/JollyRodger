extends CameraRigState


const ANGLE_X_MIN: = -PI/4
const ANGLE_X_MAX: =  PI/3


var mouse_position_saved := Vector2.ZERO


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
	


func physics_process(_delta):
	var target = camera_rig.target_ref.get_ref()
	if target:
		camera_rig.global_transform.origin = target.global_transform.origin



func input(event : InputEvent):
	
	if event is InputEventMouseButton and event.is_action_pressed("move_camera"):
		mouse_position_saved = event.position
		_parent.move_camera = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().set_input_as_handled()
	
	elif event is InputEventMouseButton and event.is_action_released("move_camera") and _parent.move_camera:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_parent.move_camera = false
		get_viewport().warp_mouse(mouse_position_saved)
		get_tree().set_input_as_handled()
	else:
		_parent.input(event)
	


func unhandled_input(event):
	
	_parent.unhandled_input(event)
	

extends CameraRigState


var move_camera := false

var _input_relative: = Vector2.ZERO



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	
	if move_camera:
	
		camera_rig.camera.translation.x = lerp(
			camera_rig.camera.translation.x,
			camera_rig.zoom,
			camera_rig.zoom_speed * delta
		)
	
	pass


func unhandled_input(event : InputEvent):
	
	if event.is_action_pressed("camera_zoom_in"):
		camera_rig.set_zoom(camera_rig.zoom - camera_rig.zoom_speed)
	elif event.is_action_pressed("camera_zoom_out"):
		camera_rig.set_zoom(camera_rig.zoom + camera_rig.zoom_speed)
	elif event is InputEventMouseMotion and move_camera: # and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_input_relative += event.get_relative()
	

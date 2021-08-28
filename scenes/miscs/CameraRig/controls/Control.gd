extends CameraRigState


export(float, 0.1, 100.0) var gamepad_view_speed := 20.0


var move_camera := false

var _input_relative: = Vector2.ZERO



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(_delta):
	
	if move_camera and Controller.type == Controller.Type.GAMEPAD:
		var look_dir = Vector2()
		look_dir += Vector2.RIGHT * Input.get_action_strength("look_right")*Input.get_action_strength("look_right")
		look_dir += Vector2.LEFT * Input.get_action_strength("look_left")*Input.get_action_strength("look_left")
		look_dir += Vector2.UP * Input.get_action_strength("look_up")*Input.get_action_strength("look_up")
		look_dir += Vector2.DOWN * Input.get_action_strength("look_down")*Input.get_action_strength("look_down")
		
		if look_dir.length_squared() > 0.0:
			_input_relative += look_dir * gamepad_view_speed
		else:
			move_camera = false
	


func input(event : InputEvent):
	
	if event.is_action_pressed("camera_zoom_in"):
		camera_rig.set_zoom(camera_rig.zoom - camera_rig.zoom_speed)
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("camera_zoom_out"):
		camera_rig.set_zoom(camera_rig.zoom + camera_rig.zoom_speed)
		get_tree().set_input_as_handled()
	if event is InputEventMouseMotion and move_camera:
		_input_relative += event.get_relative()
	


func unhandled_input(event : InputEvent):
	
	if event.is_action_pressed("camera_zoom_in"):
		camera_rig.set_zoom(camera_rig.zoom - camera_rig.zoom_speed)
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("camera_zoom_out"):
		camera_rig.set_zoom(camera_rig.zoom + camera_rig.zoom_speed)
		get_tree().set_input_as_handled()
	if event is InputEventMouseMotion and move_camera:
		_input_relative += event.get_relative()
	

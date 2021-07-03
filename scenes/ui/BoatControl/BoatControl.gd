extends Control


export(NodePath) var boat_path


onready var boat : RigidBody = get_node(boat_path)


var move_forward := false
var move_backward := false
var move_right := false
var move_left := false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if move_forward:
		$Speed/HBoxContainer/VSlider.value += delta
	
	if move_backward:
		$Speed/HBoxContainer/VSlider.value -= delta
	
	if move_right:
		$Direction/VBoxContainer/HSlider.value += delta
	
	if move_left:
		$Direction/VBoxContainer/HSlider.value -= delta
	
	$Speed/HBoxContainer/Label.text = str($Speed/HBoxContainer/VSlider.value)
	$Direction/VBoxContainer/Label.text = str($Direction/VBoxContainer/HSlider.value)
	
	pass


func _physics_process(delta):
	
	if boat:
		
		#var rotation_vec = -boat.transform.basis.y * $Direction/VBoxContainer/HSlider.value * 10
		
		#boat.add_torque(rotation_vec * 100 * delta)
		
		boat.rudder_position = $Direction/VBoxContainer/HSlider.value
		boat.sail_position = $Speed/HBoxContainer/VSlider.value
		
		#boat.add_central_force( -boat.transform.basis.z * 100 * $Speed/HBoxContainer/VSlider.value * delta )
	else:
		# print("not in water for ", boat)
		pass
	
	


func _unhandled_input(event):
	
	if event.is_action_pressed("move_forward"):
		move_backward = false
		move_forward = true
	
	if event.is_action_released("move_forward"):
		move_forward = false
	
	if event.is_action_pressed("move_backward"):
		move_backward = true
		move_forward = false
	
	if event.is_action_released("move_backward"):
		move_backward = false
	
	if event.is_action_pressed("move_right"):
		move_right = true
		move_left = false
	
	if event.is_action_released("move_right"):
		move_right = false
	
	if event.is_action_pressed("move_left"):
		move_left = true
		move_right = false
	
	if event.is_action_released("move_left"):
		move_left = false
	
	

extends Control


export(NodePath) var boat_path


onready var boat : RigidBody setget set_boat

onready var rudder_control = $Direction/VBoxContainer/HSlider


var move_forward := false
var move_backward := false
var move_right := false
var move_left := false



var rudder_near_zero := false
var rudder_near_zero_time := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	if boat_path:
		boat = get_node(boat_path)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if move_forward:
		$Speed/HBoxContainer/VSlider.value += delta
	
	if move_backward:
		$Speed/HBoxContainer/VSlider.value -= delta
	
	if move_right:
		rudder_control.value += delta
	
	if move_left:
		rudder_control.value -= delta
	
	$Speed/HBoxContainer/Label.text = str($Speed/HBoxContainer/VSlider.value)
	$Direction/VBoxContainer/Label.text = str(rudder_control.value)
	
	if abs(rudder_control.value) < 0.17 and rudder_control.value != 0.0:
		rudder_near_zero_time += delta
	else:
		rudder_near_zero_time = 0.0
	
	if rudder_near_zero_time > 3.0:
		rudder_near_zero_time = 0.0
		$Direction/RudderZeroTween.interpolate_property(
			rudder_control, "value",
			rudder_control.value, 0.0, 1.0,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Direction/RudderZeroTween.start()
	


func _physics_process(_delta):
	
	if boat:
		
		boat.rudder_position = $Direction/VBoxContainer/HSlider.value
		boat.sail_position = $Speed/HBoxContainer/VSlider.value
		


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
	


func set_boat(value):
	
	boat = value
	$Direction/VBoxContainer/HSlider.value = 0
	$Speed/HBoxContainer/VSlider.value = 0
	

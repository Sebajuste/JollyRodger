extends Control


export(NodePath) var ship_path


onready var ship_ref

onready var sails_label = $VBoxContainer/HBoxContainer/SailsControl/Label
onready var sails_control = $VBoxContainer/HBoxContainer/SailsControl/VSlider
onready var rudder_label = $VBoxContainer/RudderControl/Label
onready var rudder_control = $VBoxContainer/RudderControl/HSlider

onready var position_value = $VBoxContainer/HBoxContainer/VBoxContainer/Position/Value
onready var azimut_value = $VBoxContainer/HBoxContainer/VBoxContainer/Direction/Value
onready var speed_value = $VBoxContainer/HBoxContainer/VBoxContainer/Speed/Value
onready var health_value = $VBoxContainer/HBoxContainer/VBoxContainer/Health/Value


var move_forward := false
var move_backward := false
var move_right := false
var move_left := false



var rudder_near_zero := false
var rudder_near_zero_time := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	if ship_path:
		ship_ref = weakref(get_node(ship_path))
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if not ship_ref:
		return
	
	var ship = ship_ref.get_ref()
	
	if not ship:
		return
	
	position_value.text = str( "x: %d, y: %d, z: %d" % [
		ship.global_transform.origin.x,
		ship.global_transform.origin.y,
		ship.global_transform.origin.z
	] )
	
	var dir := Vector2(-ship.global_transform.basis.z.x, -ship.global_transform.basis.z.z)
	var angle := rad2deg( dir.angle() )
	if angle < 0:
		angle = 360 - abs(angle)
	azimut_value.text = str( round(angle) )
	
	var speed := Vector2(ship.linear_velocity.x, ship.linear_velocity.z)
	
	var knot := speed.length() * 1.852
	
	speed_value.text = str( round(knot * 10) / 10 )
	
	health_value.text = str(ship.damage_stats.health)
	
	if move_forward:
		sails_control.value += delta
	
	if move_backward:
		sails_control.value -= delta
	
	if move_right:
		rudder_control.value += delta
	
	if move_left:
		rudder_control.value -= delta
	
	sails_label.text = str(sails_control.value)
	rudder_label.text = str(rudder_control.value)
	
	if abs(rudder_control.value) < 0.17 and rudder_control.value != 0.0:
		rudder_near_zero_time += delta
	else:
		rudder_near_zero_time = 0.0
	
	if rudder_near_zero_time > 3.0:
		rudder_near_zero_time = 0.0
		$RudderZeroTween.interpolate_property(
			rudder_control, "value",
			rudder_control.value, 0.0, 1.0,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$RudderZeroTween.start()
	


func _physics_process(_delta):
	if ship_ref:
		var ship = ship_ref.get_ref()
		if ship:
			ship.rudder_position = rudder_control.value
			ship.sail_position = sails_control.value


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
	


func set_ship(value):
	if value:
		ship_ref = weakref(value)
	rudder_control.value = 0
	sails_control.value = 0

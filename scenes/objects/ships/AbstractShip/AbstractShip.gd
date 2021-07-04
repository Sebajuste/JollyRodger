class_name AbstractShip
extends RigidBody


export var water_drag := 2.0 # 0.99
export var water_angular_drag := 2.0 # 0.5

export var depth_before_submerged := 2.5
export var displacement_amount := 0.5

export var rudder_force := 10.0
export var sail_force := 10.0

export var selectable := true setget set_selectable


onready var float_manager = $FloatManager
onready var damage_stats := $DamageStats
onready var rudder : Position3D = $Rudder
onready var flag = $Flag
onready var sticker := $"3DSticker"

var rudder_position := 0.0 setget set_rudder_position
var sail_position := 0.0 setget set_sail_position

var alive := true


# Called when the node enters the scene tree for the first time.
func _ready():
	
	for child in float_manager.get_children():
		if child is WaterFloater:
			child.water_drag = water_drag
			child.water_angular_drag = water_angular_drag
			child.depth_before_submerged = depth_before_submerged
			child.displacement_amount = displacement_amount
	
	set_selectable(selectable)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(delta):
	
	if float_manager.is_in_water() and alive:
		add_torque(
			-self.transform.basis.y * rudder_position * rudder_force
		)
		add_central_force( -self.transform.basis.z * sail_position * sail_force)
	
	if is_network_master() and Vector3.UP.dot( global_transform.basis.y ) < 0.0:
		var hit := Hit.new($DamageStats.health)
		$DamageStats.take_damage(hit)
	
	
	if global_transform.origin.y < -200.0:
		queue_free()
	


func _integrate_forces(state : PhysicsDirectBodyState):
	
	$NetSyncShip.integrate_forces(state)
	


func set_rudder_position(value):
	
	rudder_position = clamp(value, -1.0, 1.0)
	


func set_sail_position(value):
	
	sail_position = clamp(value, 0.0, 1.0)
	


func set_selectable(value):
	
	selectable = value
	$SelectArea.input_ray_pickable = value
	



func _on_DamageStats_health_changed(new_value, old_value):
	pass # Replace with function body.


func _on_DamageStats_health_depleted():
	
	$"3DSticker".visible = false
	
	$SinkTween.interpolate_method($FloatManager, "set_displacement_amount",
		displacement_amount, 0.0, 60.0,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$SinkTween.start()
	
	alive = false
	

class_name AbstractShip
extends RigidBody


export var water_drag := 2.0 # 0.99
export var water_angular_drag := 2.0 # 0.5

export var depth_before_submerged := 2.5
export var displacement_amount := 0.5

export var rudder_force := 10.0
export var sail_force := 10.0


onready var float_manager = $FloatManager
onready var rudder : Position3D = $Rudder
onready var sticker := $"3DSticker"

var rudder_position := 0.0 setget set_rudder_position
var sail_position := 0.0 setget set_sail_position



# Called when the node enters the scene tree for the first time.
func _ready():
	
	for child in float_manager.get_children():
		if child is WaterFloater:
			child.water_drag = water_drag
			child.water_angular_drag = water_angular_drag
			child.depth_before_submerged = depth_before_submerged
			child.displacement_amount = displacement_amount
		
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(delta):
	
	if float_manager.is_in_water():
		add_torque(
			-self.transform.basis.y * rudder_position * rudder_force
		)
		
		add_central_force( -self.transform.basis.z * sail_position * sail_force)
	


func _integrate_forces(state : PhysicsDirectBodyState):
	
	$NetSyncShip.integrate_forces(state)
	


func set_rudder_position(value):
	
	rudder_position = clamp(value, -1.0, 1.0)
	


func set_sail_position(value):
	
	sail_position = clamp(value, 0.0, 1.0)
	

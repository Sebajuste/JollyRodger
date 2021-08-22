class_name AbstractShip
extends RigidBody


var CRATE_SCENE = preload("res://scenes/objects/Crate/Crate.tscn")


signal destroyed


export var water_drag := 2.0 # 0.99
export var water_angular_drag := 2.0 # 0.5

export var depth_before_submerged := 2.5
export var displacement_amount := 0.5

export var rudder_force := 10.0
export var sail_force := 10.0

export var selectable := true setget set_selectable
export var drop_inventory := true
export var drop_equipment := true

export(String, "None", "AI") var control_mode = "None" setget set_control_mode

export(String, "None", "GB", "Spain", "Pirate") var faction = "None" setget set_faction

export var label : String = "" setget set_label


onready var float_manager = $FloatManager
onready var damage_stats := $DamageStats
onready var rudder : Position3D = $Rudder
onready var cannons = $Cannons
onready var flag = $Flag
onready var lights = $Lights
onready var sticker := $Sticker3D

onready var inventory : Inventory = $Inventory
onready var equipment : Inventory = $Equipment

onready var control_sm := $ControlSM

onready var detection_area := $DetectionArea

onready var username_label := $Sticker3D/Control/StickerUsername

var rudder_position := 0.0 setget set_rudder_position
var sail_position := 0.0 setget set_sail_position

var alive := true setget set_alive

var speed := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for child in float_manager.get_children():
		if child is WaterFloater:
			child.water_drag = water_drag
			child.water_angular_drag = water_angular_drag
			child.depth_before_submerged = depth_before_submerged
			child.displacement_amount = displacement_amount
	
	set_selectable(selectable)
	set_control_mode(control_mode)
	set_faction(faction)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(_delta):
	
	if float_manager.is_in_water() and alive:
		add_torque(
			-self.transform.basis.y * rudder_position * rudder_force
		)
		add_central_force( -self.transform.basis.z * sail_position * sail_force)
	
	if Vector3.UP.dot( global_transform.basis.y ) < 0.0:
		if not Network.enabled or is_network_master():
			var hit := Hit.new(damage_stats.health, self.get_path())
			damage_stats.take_damage(hit)
	
	for water_mesh in get_tree().get_nodes_in_group("water_mesh"):
		
		var wave_height : float = water_mesh.get_wave_height( self.global_transform.origin )
		
		if global_transform.origin.y - wave_height < -2.0 and not alive:
			lights.visible = false
	
	speed = linear_velocity.length()
	
	if global_transform.origin.y < -200.0:
		queue_free()
	


func _integrate_forces(state : PhysicsDirectBodyState):
	
	$NetSyncShip.integrate_forces(state)
	


func is_alive() -> bool:
	
	return alive
	


func set_rudder_position(value):
	
	rudder_position = clamp(value, -1.0, 1.0)
	


func set_sail_position(value):
	
	sail_position = clamp(value, 0.0, 1.0)
	


func set_alive(value):
	alive = value
	sticker.visible = alive
	username_label.visible = alive


func set_selectable(value):
	
	selectable = value
	$SelectArea.input_ray_pickable = value
	


func set_control_mode(value):
	if Network.enabled and not is_network_master():
		return
	control_mode = value
	if control_sm:
		control_sm.transition_to("Control/%s" % value)


func set_faction(value):
	faction = value
	if flag:
		flag.faction = value


func set_label(value):
	label = value
	if username_label:
		username_label.text = value


func _sink(duration := 60):
	$SinkTween.interpolate_method($FloatManager, "set_displacement_amount",
		displacement_amount, 0.0, duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$SinkTween.start()


func _move_in_ground(duration : float = 30):
	var start_pos := global_transform
	var end_pos := Transform(global_transform)
	end_pos.origin = end_pos.origin + Vector3.DOWN * 5
	$SinkTween.interpolate_property(self, "global_transform",
		start_pos, end_pos, duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$SinkTween.start()


func _drop():
	
	if Network.enabled and not is_network_master():
		push_warning("Ship drop() called on slave node")
		return
	
	if (not drop_equipment or not equipment.has_items()) and (not drop_inventory or not inventory.has_items()):
		return
	
	var crate = CRATE_SCENE.instance()
	crate.set_network_master( 1 )
	crate.name = "%s_%d_%d" % [crate.name, 1, randi()]
	
	var dir := Vector3(
		rand_range(-1, 1),
		0,
		rand_range(-1, 1)
	).normalized()
	
	var crate_pos := global_transform.origin + dir*10 + dir*randf()*10
	crate.transform.origin = crate_pos
	
	Spawner.spawn(crate)
	
	if drop_equipment and equipment.has_items():
		var keys = equipment.items.keys()
		for key_index in range(keys.size()):
			var item_slot = keys[key_index]
			var item = equipment.items[item_slot]
			var crate_index : int = crate.inventory.get_free_slot()
			if crate_index != -1:
				equipment.remove_item(item_slot)
				crate.inventory.add_item(crate_index, item)
			else:
				break
	
	if drop_inventory and inventory.has_items():
		var keys = inventory.items.keys()
		for key_index in range(keys.size()):
			var item_slot = keys[key_index]
			var item = inventory.items[item_slot]
			var crate_index : int = crate.inventory.get_free_slot()
			if crate_index != -1:
				inventory.remove_item(item_slot)
				crate.inventory.add_item(crate_index, item)
			else:
				break
		


func _on_DamageStats_health_depleted():
	
	if sticker:
		sticker.visible = false
		username_label.visible = false
	
	$AnimationPlayer.play("sink")
	
	alive = false
	_drop()
	emit_signal("destroyed")

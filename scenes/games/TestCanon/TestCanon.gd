extends Spatial



onready var canon := $Cannons/Cannon
onready var target := $Target

onready var ui_range := $CanvasLayer/Status/VBoxContainer/Range


var last_target_position := Vector3.ZERO

var target_velocity := Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if not target or not canon:
		return
	
	var target_offset : Vector3 = canon.global_transform.origin - target.global_transform.origin
	
	if target_offset.length() + 1 > canon.max_range:
		
		ui_range.get_node("Value").text = "Out of range"
		
	else:
		ui_range.get_node("Value").text = "In range"
		
		if canon.fire_ready:
			canon.fire(target.global_transform.origin, target_velocity)
		


func _physics_process(delta : float):
	
	var target_offset : Vector3 = target.global_transform.origin - last_target_position
	
	var target_dir := target_offset.normalized()
	
	var target_speed := target_offset.length() / delta
	
	target_velocity = target_dir * target_speed
	
	last_target_position = target.global_transform.origin
	
	
	
	canon.look_at(target.global_transform.origin, Vector3.UP)
	
	


func _unhandled_input(event):
	
	if event.is_action_pressed("ui_accept"):
		
		
		pass
	

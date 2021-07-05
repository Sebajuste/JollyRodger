class_name CameraRig
extends Spatial


export(String, "Follow", "Gimbal") var mode := "Follow" setget set_mode

export(NodePath) var target_path

export var min_distance := 1.0
export var max_distance := 60.0
export var distance := 30.0

export var rotation_speed := 0.1 # PI / 2

#export var zoom_min := 1.0
#export var zoom_max := 3.0
export var zoom_range := Vector2(1.0, 10.0) setget set_zoom_range
export var zoom := 1.5 setget set_zoom
export var zoom_speed := 1.5

export var current := false setget set_current

onready var target : Spatial
onready var pivot : Spatial = $Pivot
onready var camera : Camera = $Pivot/InterpolatedCamera
onready var spring_arm : SpringArm = $Pivot/SpringArm


# Called when the node enters the scene tree for the first time.
func _ready():
	
	if target_path:
		target = get_node(target_path)
	
	set_mode(mode)
	set_zoom_range(zoom_range)
	set_zoom(zoom)
	set_current(current)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	spring_arm.spring_length = lerp(spring_arm.spring_length, zoom, delta)
	
	pass


func set_mode(value):
	mode = value
	$ControlSM.transition_to("Control/%s" % value)


func set_zoom_range(value):
	value.x = max(value.x, 0.0)
	value.y = max(value.y, 0.0)
	zoom_range.x = min(value.x, value.y)
	zoom_range.y = max(value.x, value.y)


func set_zoom(value):
	
	zoom = clamp(value, zoom_range.x, zoom_range.y)
	


func set_current(value):
	
	current = value
	if camera:
		camera.current = value
	

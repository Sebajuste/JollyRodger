extends Node


export(NodePath) var sky_path


onready var sky = get_node(sky_path)

export var global_time_speed := 1
export var day_time_speed := 1
export var night_time_speed := 1
export var hour_start_day := 6
export var hour_start_night := 18



var hours := 9
var minutes := 0
var seconds := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
 # set_time_of_day

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var add_seconds : float = delta * global_time_speed
	
	if hours >= hour_start_day and hours < hour_start_night:
		add_seconds *= day_time_speed
	else:
		add_seconds *= night_time_speed
	
	seconds += add_seconds
	
	if seconds >= 60:
		minutes += 1
		seconds = 0
	if minutes >= 60:
		hours = wrapi(hours+1, 0, 24)
		minutes = 0
	
	#sky.set_time_of_day( sky.time_of_day + sky.one_second )
	
	sky.set_time_of_day((hours*3600+minutes*60+int(seconds) ) * sky.one_second)
	
	pass

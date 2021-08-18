extends Node


export(NodePath) var sky_path
export(NodePath) var ocean_path
export(Resource) var start_weather
export var weather_change_speed : float = 0.5


onready var sky : GameSky = get_node(sky_path)
onready var ocean : Ocean = get_node(ocean_path)
onready var rain := $Rain

var weather : GameWeater setget set_weather
#var rain_amount := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	rain.set_as_toplevel(true)
	
	if start_weather is GameWeater:
		weather = start_weather
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if sky is GameSky:
		sky.clouds_coverage = lerp(sky.clouds_coverage, weather.coverage, delta * weather_change_speed)
	
	if ocean is Ocean:
		ocean.amplitude = lerp(ocean.amplitude, weather.ocean_amplitude, delta * weather_change_speed)
		ocean.steepness = lerp(ocean.steepness, weather.ocean_steepness, delta * weather_change_speed)
	
	#rain_amount = lerp(rain_amount, weather.rain, delta)
	#rain.amount = max(int(rain_amount), 1)
	
	rain.emitting = true if  weather.rain > 0 else false
	
	pass


func _physics_process(_delta):
	var camera := get_viewport().get_camera()
	if camera and rain:
		rain.global_transform.origin = camera.global_transform.origin + Vector3.UP * 10
	


func set_weather(value):
	weather = value

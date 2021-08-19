extends Node


signal weather_changed(weather)


export(OpenSimplexNoise) var weather_noise : OpenSimplexNoise = OpenSimplexNoise.new()
export(NodePath) var sky_path
export(NodePath) var ocean_path
export(Resource) var weather_step0
export(Resource) var weather_step1
export(Resource) var weather_step2
export(float, 0.1, 100.0, 0.1) var weather_change_speed : float = 1.0
export(float, 0.1, 10.0, 0.1)  var weather_interpolation_speed : float = 0.5


onready var sky : GameSky = get_node(sky_path)
onready var ocean : Ocean = get_node(ocean_path)
onready var rain_1 := $Rain1
onready var rain_2 := $Rain2
onready var rain_3 := $Rain3


var weather : GameWeater setget set_weather
var weather_offset := 0.0


func _init():
	
	set_network_master(1)
	


# Called when the node enters the scene tree for the first time.
func _ready():
	rain_1.set_as_toplevel(true)
	rain_2.set_as_toplevel(true)
	rain_3.set_as_toplevel(true)
	
	update_cloud_config()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	weather_offset += delta * weather_change_speed
	
	var noise_1d : float = weather_noise.get_noise_1d(weather_offset)
	
	var weather_value := (noise_1d+1) / 2.0
	
	var weather_pow := weather_value*weather_value
	
	var clouds_coverage := 0.0
	var wind_strength := 0.0
	var rain := 0
	
	
	if weather_pow > 0.5:
		var val := weather_pow - 0.5
		
		var clouds_coverage_delta : float = weather_step2.clouds_coverage - weather_step1.clouds_coverage
		clouds_coverage = (val * clouds_coverage_delta) / 0.5 + weather_step1.clouds_coverage
		
		var wind_strength_delta : float = weather_step2.wind_strength - weather_step1.wind_strength
		wind_strength = (val * wind_strength_delta) / 0.5 + weather_step1.wind_strength
		
	else:
		var val := weather_pow
		
		var clouds_coverage_delta : float = weather_step2.clouds_coverage - weather_step1.clouds_coverage
		clouds_coverage = (val * clouds_coverage_delta) / 0.5 + weather_step1.clouds_coverage
		
		var wind_strength_delta : float = weather_step2.wind_strength - weather_step1.wind_strength
		wind_strength = (val * wind_strength_delta) / 0.5 + weather_step1.wind_strength
	
	
	if weather_pow > 0.60:
		rain = weather_step2.rain
		#set_weather(weather_step2)
	elif weather_pow > 0.30:
		rain = weather_step1.rain
		#set_weather(weather_step1)
	else:
		rain = weather_step0.rain
		#set_weather(weather_step0)
	
	
	if sky is GameSky:
		sky.clouds_coverage = lerp(sky.clouds_coverage, clouds_coverage, delta * weather_interpolation_speed)
	
	if ocean is Ocean:
		ocean.wind_strength = lerp(ocean.wind_strength, wind_strength, delta * weather_interpolation_speed)
	
	match Configuration.Settings.Display.RainDetails:
		"ultra":
			rain_1.visible = true
			rain_1.emitting = true if rain > 0 else false
			rain_2.visible = true
			rain_2.emitting = true if rain > 0 else false
			rain_3.visible = true
			rain_3.emitting = true if rain > 0 else false
		"high":
			rain_1.visible = true
			rain_1.emitting = true if rain > 0 else false
			rain_2.visible = true
			rain_2.emitting = true if rain > 0 else false
			rain_3.emitting = false
			rain_3.visible = false
		"medium":
			rain_1.visible = true
			rain_1.emitting = true if rain > 0 else false
			rain_2.visible = false
			rain_2.emitting = false
			rain_3.emitting = false
			rain_3.visible = false
		"low":
			rain_1.visible = false
			rain_1.emitting = false
			rain_2.visible = true
			rain_2.emitting = true if rain > 0 else false
			rain_3.visible = false
			rain_3.emitting = false
	
	$RainSound.playing = true if rain > 0 else false
	
	pass


func _physics_process(_delta):
	var camera := get_viewport().get_camera()
	if camera:
		var particules_pos := camera.global_transform.origin -camera.global_transform.basis.z * 5 + Vector3.UP * 10
		if rain_1:
			rain_1.global_transform.origin = particules_pos
		if rain_2:
			rain_2.global_transform.origin = particules_pos
		if rain_3:
			rain_3.global_transform.origin = particules_pos
	


func update_cloud_config():
	
	if sky:
		sky.clouds_quality = Configuration.Settings.Display.CloudsQuality
	


func set_weather(value):
	if value != null and weather != value:
		weather = value
		emit_signal("weather_changed", weather)
	

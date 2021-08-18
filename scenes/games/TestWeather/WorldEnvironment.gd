extends WorldEnvironment


export(Resource) var weather setget set_weather
export var sun_position := Vector3(0, abs(sin(0.3)), -1) setget set_sun_position
export var sun_color := Color.white setget set_sun_color
export var weather_speed_change := 10
export var cloud_step := 25 setget set_cloud_step
onready var sky_material : Material = $SkyTexture/Sky.material
onready var sun : DirectionalLight = $Sun

var coverage : float = 30.0 setget set_coverage
var absorption : float = 7.0 setget set_absorption
var thickness : float = 25.0 setget set_thickness
var time := 0.0



# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Sun.light_color = sun_color
	
	var iChannel = $SkyTexture.get_viewport().get_texture()
	environment.background_sky.set_panorama(iChannel)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	
	if coverage != weather.coverage:
		coverage = lerp(coverage, weather.coverage, delta / weather_speed_change)
		sky_material.set("shader_param/COVERAGE", float(coverage)/100)
	
	if absorption != weather.absorption:
		absorption = lerp(absorption, weather.absorption, delta / weather_speed_change)
		sky_material.set("shader_param/ABSORPTION", float(absorption)/10)
	
	if thickness != weather.thickness:
		thickness = lerp(thickness, weather.thickness, delta / weather_speed_change)
		sky_material.set("shader_param/THICKNESS", thickness)
	
	environment.fog_depth_begin = lerp(environment.fog_depth_begin, weather.fog_begin, delta / weather_speed_change)
	environment.fog_depth_end = lerp(environment.fog_depth_end, weather.fog_end, delta / weather_speed_change)
	
	sky_material.set("shader_param/iTime", time)


func _physics_process(delta):
	
	
	var t = sun.transform
	t.origin = sun_position
	sun.transform = t.looking_at(Vector3(0.0, 0.0, 0.0), Vector3(0.0, 1.0, 0.0))
	#sun.light_energy = 1.0 - clamp(abs(hours - 12.0) / 6.0, 0.0, 1.0)
	


func set_weather(value):
	weather = value


func set_coverage(value):
	coverage = value
	if sky_material:
		sky_material.set("shader_param/COVERAGE", float(coverage)/100)


func set_absorption(value):
	absorption = value
	if sky_material:
		sky_material.set("shader_param/ABSORPTION",float(absorption)/10)


func set_thickness(value):
	thickness = value
	if sky_material:
		sky_material.set("shader_param/THICKNESS", thickness)


func set_sun_color(value):
	sun_color = value
	if sky_material:
		sky_material.set("shader_param/sun_color", sun_color)
	if sun:
		sun.light_color = sun_color


func set_sun_position(value : Vector3):
	sun_position = value.normalized()
	if sky_material:
		sky_material.set("shader_param/sun_dir", sun_position)


func set_cloud_step(value):
	cloud_step = value
	if sky_material:
		sky_material.set("shader_param/STEPS", cloud_step)

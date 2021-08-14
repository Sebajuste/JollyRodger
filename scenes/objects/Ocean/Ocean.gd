tool
class_name Ocean
extends Spatial



class WaveConfiog:
	var direction : Vector2
	var steepness : float
	var wavelength : float



export var wave_direction := Vector2(1.0, 0.1) setget set_wave_direction
export var amplitude := 1.0 setget set_amplitude
export(float, 0.0, 1.0) var steepness := 0.25 setget set_steepness


onready var meshes := $Meshes


var wave_a := {
	"direction": Vector2(1.0, 1.0),
	"steepness": 0.25,
	"wavelength": 60.0
}

var wave_b := {
	"direction": Vector2(1.0, 0.6),
	"steepness": 0.25,
	"wavelength": 30.0
}

var wave_c := {
	"direction": Vector2(1.0, 1.3),
	"steepness": 0.25,
	"wavelength": 15.0
}


var ocean_time := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	wave_a.wavelength = amplitude * 4
	wave_b.wavelength = amplitude * 2
	wave_c.wavelength = amplitude
	
	wave_a.steepness = steepness
	wave_b.steepness = steepness
	wave_c.steepness = steepness
	
	update_shader()
	
	if not Network.enabled or is_network_master():
		
		$NetNodeSync/Timer.start()
		
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	ocean_time += delta
	
	var camera := get_viewport().get_camera()
	if camera and not Engine.editor_hint:
		self.global_transform.origin = Vector3(
			camera.global_transform.origin.x,
			0,
			camera.global_transform.origin.z
		)
	
	if meshes:
		for ocean_mesh in meshes.get_children():
			ocean_mesh.material_override.set_shader_param("ocean_time", ocean_time)
	

func update_shader():
	
	if not meshes:
		return
	
	for ocean_mesh in meshes.get_children():
		
		# var w_dir : Vector2 =  wave_direction.normalized()
		
		wave_a.direction = wave_direction.normalized()
		wave_b.direction = wave_a.direction.rotated(PI/5)
		wave_c.direction = wave_b.direction.rotated(PI/8)
		
		ocean_mesh.material_override.set_shader_param("wave_a_direction", wave_a.direction )
		ocean_mesh.material_override.set_shader_param("wave_a_steepness", wave_a.steepness )
		ocean_mesh.material_override.set_shader_param("wave_a_wavelength", wave_a.wavelength )
		
		ocean_mesh.material_override.set_shader_param("wave_b_direction", wave_b.direction )
		ocean_mesh.material_override.set_shader_param("wave_b_steepness", wave_b.steepness )
		ocean_mesh.material_override.set_shader_param("wave_b_wavelength", wave_b.wavelength )
		
		ocean_mesh.material_override.set_shader_param("wave_c_direction", wave_c.direction )
		ocean_mesh.material_override.set_shader_param("wave_c_steepness", wave_c.steepness )
		ocean_mesh.material_override.set_shader_param("wave_c_wavelength", wave_c.wavelength )


func get_wave_height(position : Vector3) -> float:
	
	var wave_pos = Vector2(position.x, position.z)
	
	var p = Vector3(position.x, 0.0, position.z)
	
	p += _gerstner_wave(wave_a, wave_pos, ocean_time);
	p += _gerstner_wave(wave_b, wave_pos, ocean_time);
	p += _gerstner_wave(wave_c, wave_pos, ocean_time);
	
	return p.y


func _gerstner_wave(wave : Dictionary, p : Vector2, time : float) -> Vector3:
	
	var s : float = wave.steepness
	var wavelength : float = wave.wavelength
	
	var k := 2.0 * PI / wavelength
	var c := sqrt(9.8 / k)
	var d := Vector2(wave.direction.x, wave.direction.y).normalized()
	var f := k * (d.dot( Vector2(p.x, p.y) ) - c * time);
	var a := s / k;
	
	"""
	return Vector3(
		d.x * (a * cos(f)),
		a * sin(f),
		d.y * (a * cos(f))
	)
	"""
	
	return Vector3(
		0.0,
		a * sin(f),
		0.0
	)


func set_wave_direction(value):
	wave_direction = value
	update_shader()


func set_amplitude(value):
	amplitude = value
	wave_a.wavelength = amplitude * 4
	wave_b.wavelength = amplitude * 2
	wave_c.wavelength = amplitude
	update_shader()


func set_steepness(value):
	steepness = value
	wave_a.steepness = steepness
	wave_b.steepness = steepness
	wave_c.steepness = steepness
	update_shader()

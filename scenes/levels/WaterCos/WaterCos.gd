extends Spatial


export(float, 0.1, 10.0) var wave_height := 2.0 setget set_wave_height
export var wave_factor := 0.2 setget set_wave_factor
export var wave_speed := 5.0 setget set_wave_speed


onready var mesh_instance := $MeshInstance


var time := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_wave_height(wave_height)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	var camera := get_viewport().get_camera()
	if camera and not Engine.editor_hint:
		self.global_transform.origin = Vector3(
			camera.global_transform.origin.x,
			0,
			camera.global_transform.origin.z
		)
	
	time += delta
	
	if mesh_instance:
		mesh_instance.mesh.get_material().set_shader_param("water_time", time)
	


func get_wave_height(position : Vector3) -> float:
	var time_factor := wave_speed * time
	var height := cos( (position.x + time_factor) * wave_factor) * sin( (position.z + time_factor) * wave_factor) * wave_height
	return height


func set_wave_height(value):
	wave_height = value
	if mesh_instance:
		mesh_instance.mesh.get_material().set_shader_param("wave_height", wave_height)


func set_wave_factor(value):
	wave_factor = value
	if mesh_instance:
		mesh_instance.mesh.get_material().set_shader_param("wave_factor", wave_factor)


func set_wave_speed(value):
	wave_speed = value
	if mesh_instance:
		mesh_instance.mesh.get_material().set_shader_param("wave_speed", wave_speed)
	

tool
extends MeshInstance


export var deep_offset := 30


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(_delta):
	var camera := get_viewport().get_camera()
	if camera:
		global_transform.origin = camera.global_transform.origin
		global_transform.origin.y = -deep_offset

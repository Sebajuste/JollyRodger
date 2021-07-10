extends Spatial



export var offset := Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(_delta):
	
	self.global_transform.origin = get_parent().global_transform.origin + offset
	

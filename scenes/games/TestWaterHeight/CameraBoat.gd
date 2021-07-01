extends Camera



export var offset_y := 10.0
export var distance := 30.0


onready var target : Spatial = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_as_toplevel(true)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _process(_delta):
	
	var offset := self.global_transform.origin - target.global_transform.origin
	
	offset = offset.normalized() * distance
	offset.y = target.global_transform.origin.y + offset_y
	
	look_at_from_position(
		target.global_transform.origin + offset,
		target.global_transform.origin,
		Vector3.UP
	)
	

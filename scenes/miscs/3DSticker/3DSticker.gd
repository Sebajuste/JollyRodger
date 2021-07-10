extends Spatial


#export var text := "" setget set_text
#export var use_parent_name := false


#onready var parent := get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	"""
	if use_parent_name:
		parent.connect("renamed", self, "_node_renamed")
	
	$Control/Username.text = parent.name
	"""
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var pos = global_transform.origin
	var cam = get_tree().get_root().get_camera()
	if cam:
		var cam_dir = (cam.global_transform.origin - global_transform.origin).normalized()
		var cam_dot = cam_dir.dot( cam.global_transform.basis.z )
		if cam_dot > 0.0:
			var screen_pos = cam.unproject_position(pos)
			$Control.set_position( Vector2(screen_pos.x - $Control.rect_size.x/2, screen_pos.y - $Control.rect_size.y/2) )
			$Control.visible = true
		else:
			$Control.visible = false
	

"""
func set_text(value):
	
	text = value
	$Control/Label.text = value
	


func _node_renamed():
	
	$Control/Username.text = parent.name
	
"""


func _on_Sticker3D_visibility_changed():
	
	$Control.visible = self.visible
	
	pass # Replace with function body.

extends Control


export(NodePath) var target_path


onready var target := get_node(target_path)


var resize_position = null


# Called when the node enters the scene tree for the first time.
func _ready():
	
	if not target:
		target = get_parent()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Resizable_gui_input(event):
	
	if event is InputEventMouseButton:
		
		if event.pressed:
			resize_position = get_global_mouse_position() - target.rect_size
		else:
			resize_position = null
	
	if event is InputEventMouseMotion and resize_position:
		
		var screen_size : Vector2 = get_viewport().size
		
		var new_size : Vector2 = get_global_mouse_position() - resize_position
		
		target.rect_size.x = clamp(new_size.x, 0, screen_size.x - target.rect_global_position.x)
		target.rect_size.y = clamp(new_size.y, 0, screen_size.y - target.rect_global_position.y)
	

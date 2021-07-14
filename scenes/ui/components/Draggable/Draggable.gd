extends Control


export(NodePath) var target_path


onready var target := get_node(target_path)


var drag_position = null


# Called when the node enters the scene tree for the first time.
func _ready():
	
	if not target:
		target = get_parent()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Draggable_gui_input(event):
	
	if event is InputEventMouseButton:
		
		if event.pressed:
			drag_position = get_global_mouse_position() - target.rect_global_position
		else:
			drag_position = null
	
	if event is InputEventMouseMotion and drag_position:
		
		var screen_size : Vector2 = get_viewport().size
		
		var new_pos : Vector2 = get_global_mouse_position() - drag_position
		
		target.rect_global_position.x = clamp(new_pos.x, 0, screen_size.x - target.rect_size.x)
		target.rect_global_position.y = clamp(new_pos.y, 0, screen_size.y - target.rect_size.y)
		

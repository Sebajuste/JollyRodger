extends Area


signal object_selected(object)


export var group_target := ""


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SelectArea_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	
	if event is InputEventMouseButton:
		
		if event.button_index == BUTTON_LEFT and event.pressed:
			print("event in selector")
			var target := owner
			
			if group_target == "" or target.is_in_group(group_target):
				emit_signal("object_selected", target)
				if ObjectSelector:
					ObjectSelector.emit_signal("object_selected", target, self)
	

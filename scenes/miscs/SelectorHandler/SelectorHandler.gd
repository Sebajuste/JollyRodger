extends Node


signal selected(target)
signal unselected(target)


var SELECT_HINT_SCENE = preload("res://scenes/miscs/SelectHint/SelectHint.tscn")


export(float, 0.1, 2.0) var select_await := 0.5


var target_ref : WeakRef
var select_hint_ref : WeakRef
var select_timer := 0.0

var exclude_select := []


# Called when the node enters the scene tree for the first time.
func _ready():
	
	#ObjectSelector.connect("object_selected", self, "_on_object_selected")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	select_timer += delta
	
	pass


func _input(event):
	
	if event is InputEventMouseButton:
		
		if event.button_index == BUTTON_LEFT and event.pressed:
			
			var mouse_pos := get_viewport().get_mouse_position()
			
			var camera := get_tree().get_root().get_camera()
			
			var from := camera.project_ray_origin(mouse_pos)
			var to := from + camera.project_ray_normal(mouse_pos) * 5000
			
			var space_state := camera.get_world().direct_space_state
			var result := space_state.intersect_ray(from, to, exclude_select, 0x0400, false, true)
			
			if result and result.has("collider"):
				
				var select_area : Area = result.collider
				var object : Spatial = select_area.object
				
				for exclude_object in exclude_select:
					if exclude_object == object or exclude_object.is_a_parent_of(object):
						return
				
				if has_select():
					
					var select = get_select()
					emit_signal("unselected", select)
				
				if not target_ref or target_ref.get_ref() == null or target_ref.get_ref() != object:
					
					var select_hint
					
					if select_hint_ref != null and select_hint_ref.get_ref() != null:
						select_hint = select_hint_ref.get_ref()
						
						var select_hint_parent : Node = select_hint.get_parent()
						if select_hint_parent:
							select_hint_parent.remove_child(select_hint)
						
					else:
						select_hint = SELECT_HINT_SCENE.instance()
					
					select_area.add_child(select_hint)
					
					target_ref = weakref(object)
					select_hint_ref = weakref(select_hint)
					
					select_timer = 0.0
					
					emit_signal("selected", object)
					
				
			elif not result or not result.has("collider"):
				
				if has_select():
					
					if select_timer > select_await and select_hint_ref != null:
						
						var select_hint = select_hint_ref.get_ref()
						if select_hint == null:
							select_hint_ref = null
						else:
							select_hint.queue_free()
						
						var target = get_select()
						target_ref = null
						
						emit_signal("unselected", target)


func has_select() -> bool:
	
	return true if target_ref and target_ref.get_ref() != null else false
	


func get_select():
	if target_ref:
		return target_ref.get_ref()
	return null

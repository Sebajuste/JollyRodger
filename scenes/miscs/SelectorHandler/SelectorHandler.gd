extends Node


var SELECT_HINT_SCENE = preload("res://scenes/miscs/SelectHint/SelectHint.tscn")


export(float, 0.1, 2.0) var select_await := 0.5


var target_ref : WeakRef
var select_hint_ref : WeakRef
var select_timer := 0.0


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
		
		if event.button_index == BUTTON_LEFT:
			
			var mouse_pos := get_viewport().get_mouse_position()
			
			var camera := get_tree().get_root().get_camera()
			
			var from := camera.project_ray_origin(mouse_pos)
			var to := from + camera.project_ray_normal(mouse_pos) * 1000
			
			var space_state := camera.get_world().direct_space_state
			var result := space_state.intersect_ray(from, to, [], 0x0400, false, true)
			
			print("pick result : ", result)
			
			if result and result.has("collider"):
				
				var select_area : Area = result.collider
				var object : Spatial = select_area.object
				
				if not target_ref or target_ref.get_ref() == null or target_ref.get_ref() != object:
					
					var select_hint
					
					if select_hint_ref != null and select_hint_ref.get_ref() != null:
						select_hint = select_hint_ref.get_ref()
					else:
						select_hint = SELECT_HINT_SCENE.instance()
					
					select_area.add_child(select_hint)
					
					target_ref = weakref(object)
					select_hint_ref = weakref(select_hint)
					
					select_timer = 0.0
				
			elif not result or not result.has("collider"):
				
				if select_timer > select_await:
					
					if select_hint_ref != null:
						
						var select_hint = select_hint_ref.get_ref()
						if select_hint == null:
							select_hint_ref = null
						else:
							select_hint.queue_free()
						
						target_ref = null
				
	

"""
func _unhandled_input(event):
	
	if event is InputEventMouseButton:
		
		if event.button_index == BUTTON_LEFT and select_timer > select_await:
			
			if select_hint_ref != null:
				
				var select_hint = select_hint_ref.get_ref()
				if select_hint == null:
					select_hint_ref = null
				else:
					select_hint.queue_free()
				
			target_ref = null
"""

func get_target():
	if target_ref:
		return target_ref.get_ref()
	return null


func _on_object_selected(object, area):
	
	if not target_ref or target_ref.get_ref() == null or target_ref.get_ref() != object:
		
		var select_hint
		
		if select_hint_ref != null and select_hint_ref.get_ref() != null:
			select_hint = select_hint_ref.get_ref()
		else:
			select_hint = SELECT_HINT_SCENE.instance()
		
		area.add_child(select_hint)
		
		target_ref = weakref(object)
		select_hint_ref = weakref(select_hint)
		
		select_timer = 0.0

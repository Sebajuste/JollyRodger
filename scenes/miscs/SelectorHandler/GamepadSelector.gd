extends Control


export var selector_speed := 20.0


var selector_position := Vector2.ZERO
var selector_moving := false


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if selector_moving:
		
		var size : Vector2 = get_viewport_rect().size
		
		var move_dir := Vector2()

		move_dir += Vector2.RIGHT * Input.get_action_strength("look_right")
		move_dir += Vector2.LEFT * Input.get_action_strength("look_left")
		move_dir += Vector2.UP * Input.get_action_strength("look_up")
		move_dir += Vector2.DOWN * Input.get_action_strength("look_down")
		
		var length_squared := move_dir.length_squared()
		if length_squared > 0.0:
			
			move_dir = move_dir.normalized() * length_squared*length_squared
			
			selector_position += move_dir * selector_speed
			
			selector_position.x = clamp(selector_position.x, 0.0, size.x)
			selector_position.y = clamp(selector_position.y, 0.0, size.y)
			
			update()
		
		pass
	
	pass


func _draw():
	if selector_moving:
		draw_arc(selector_position, 20.0, 0, 2*PI, 20, Color.white)
	


func _unhandled_input(event):
	
	if event is InputEventJoypadMotion and selector_moving:
		get_tree().set_input_as_handled()
	
	if event is InputEventJoypadButton:
		
		if event.is_action_pressed("move_selector"):
			selector_moving = true
			var size : Vector2 = get_viewport_rect().size
			selector_position.x = size.x/2
			selector_position.y = size.y/2
			visible = true
			set_process(true)
		elif event.is_action_released("move_selector"):
			selector_moving = false
			set_process(false)
			visible = false
			
			owner.select(selector_position)
	

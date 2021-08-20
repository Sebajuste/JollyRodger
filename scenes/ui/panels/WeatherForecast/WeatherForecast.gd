tool
extends Control


export(NodePath) var weather_manager_path

export var step := 25
export var weather_margin_left := 50

onready var weather_manager = get_node(weather_manager_path)


# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if weather_manager:
		update()
	pass


func _draw():
	
	if not weather_manager:
		return
	
	var offset = weather_manager.get("weather_offset") - weather_margin_left
	
	if offset == null:
		return
	
	draw_line(
		Vector2(weather_margin_left, 0),
		Vector2(weather_margin_left, rect_size.y),
		Color.red
	)
	
	draw_line(
		Vector2(0, 0),
		Vector2(rect_size.x, 0),
		Color.webgray
	)
	
	draw_line(
		Vector2(0, rect_size.y/3),
		Vector2(rect_size.x, rect_size.y/3),
		Color.webgray
	)
	
	draw_line(
		Vector2(0, (rect_size.y/3) * 2),
		Vector2(rect_size.x, (rect_size.y/3) * 2),
		Color.webgray
	)
	
	draw_line(
		Vector2(0, rect_size.y),
		Vector2(rect_size.x, rect_size.y),
		Color.webgray
	)
	
	for index in range(rect_size.x / step):
		
		var x : int = index * step
		var x_next = x + step
		
		var noise_value : float = weather_manager.weather_noise.get_noise_1d(offset + x)
		var noise_value_next: float = weather_manager.weather_noise.get_noise_1d(offset + x_next)
		
		var value := (noise_value+1) / 2.0
		var value_next := (noise_value_next+1) / 2.0
		
		var y := value * rect_size.y
		var y_next := value_next * rect_size.y
		#draw_circle( Vector2(x, rect_size.y-y), 2.0, Color.white)
		
		draw_line(
			Vector2(x, rect_size.y-y),
			Vector2(x_next, rect_size.y-y_next),
			Color.white,
			1.0
		)
		
		draw_line(
			Vector2(x, rect_size.y - value*value * rect_size.y),
			Vector2(x_next, rect_size.y - value_next*value_next * rect_size.y),
			Color.blue,
			1.0
		)
		
		#draw_circle( Vector2(x, rect_size.y - value*value * rect_size.y), 2.0, Color.blue)
		
	
	pass

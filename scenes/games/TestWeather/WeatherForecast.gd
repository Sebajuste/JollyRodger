tool
extends Control


export(NodePath) var weather_manager_path


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
	
	var offset : float = weather_manager.weather_offset
	
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
	
	
	for x in range(rect_size.x):
		
		if x % 4 != 0:
			continue
		
		var noise_1d : float = weather_manager.weather_noise.get_noise_1d(offset + x)
		
		var value := (noise_1d+1) / 2.0
		
		var y := value * rect_size.y
		draw_circle( Vector2(x, rect_size.y-y), 2.0, Color.white)
		
		
		draw_circle( Vector2(x, rect_size.y - value*value * rect_size.y), 2.0, Color.blue)
		
	
	pass

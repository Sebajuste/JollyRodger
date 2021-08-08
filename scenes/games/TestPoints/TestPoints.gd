extends Control


export var num_points := 120
export(float, 0.1, 1.0) var turn_fraction : float = 0.618033


export var highlight_offset := 0
export var highlight := 3

export var p :float = 0.5

var center := Vector2.ZERO


var cursor_index := 0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	center = Vector2(400, 300)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _draw():
	draw_circle(center, 2.0, Color.white)
	algo_3()
	


func algo_1():
	
	for i in range(num_points):
		algo_1_point(i)
	
	algo_1_point(cursor_index, Color.red)


func algo_1_point(i : int, color := Color.cyan):
	
	var dst : float = pow(i / (num_points - 1.0), p)
	var angle : float = 2 * PI * turn_fraction * i
	
	var x := dst * cos(angle)
	var y := dst * sin(angle)
	
	if (i + highlight_offset) % highlight == 0:
		color = Color.orange
	
	draw_circle(center + Vector2(x, y) * 200, 2.0, color)


func algo_2():
	
	for i in range(num_points):
		algo_2_point(i)
	
	algo_2_point(cursor_index, Color.red)


func algo_2_point(i : int, color := Color.cyan):
	
	
	var t = i / (num_points - 1.0)
	var inclination = acos(1 - 2 * t)
	var azimut = 2 * PI * turn_fraction * i
	
	var x = sin(inclination) * cos(azimut)
	var y = sin(inclination) * sin(azimut)
	var z = cos(inclination)
	
	draw_circle(center + Vector2(x, y) * 200, 2.0, color)
	


func algo_3():
	for i in range(num_points):
		algo_3_point(i)
	algo_3_point(cursor_index, Color.red)


func algo_3_point(i : int, color := Color.cyan):
	
	var dst := 1
	
	var angle := 0.0
	if i % 2:
		angle = ( i + 1) * (PI * 2 / num_points)
	else:
		angle = (-i) * (PI * 2 / num_points)
	
	var x := dst * cos(angle)
	var y := dst * sin(angle)
	
	draw_circle(center + Vector2(x, y) * 200, 2.0, color)



func _on_NumPointsSlider_value_changed(value):
	
	num_points = value
	update()
	
	pass # Replace with function body.


func _on_TurnFractionSlider_value_changed(value):
	
	turn_fraction = value
	update()
	
	pass # Replace with function body.


func _on_PowSlider_value_changed(value):
	p = value
	update()


func _on_CursorIndexSlider_value_changed(value):
	cursor_index = wrapi(value, 0, num_points)
	update()
	pass # Replace with function body.

tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _draw():
	
	var center := rect_size / 2
	
	draw_arc(
		center + Vector2(-100, 0), 50.0,
		deg2rad(90), deg2rad(270),
		10,
		Color.white
	)
	
	draw_line(
		center + Vector2(-100, 50),
		center + Vector2(100, 50),
		Color.white
	)
	draw_line(
		center + Vector2(-100, -50),
		center + Vector2(100, -50),
		Color.white
	)
	
	draw_line(
		center + Vector2(100, 50),
		center + Vector2(200, 0),
		Color.white
	)
	draw_line(
		center + Vector2(100, -50),
		center + Vector2(200, 0),
		Color.white
	)
	

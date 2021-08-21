extends ImmediateGeometry


onready var cloth := get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	# Clean up before drawing.
	clear()
	
	for spring in cloth.springs:
		
		# Begin draw.
		begin(Mesh.PRIMITIVE_LINES)
		
		add_vertex( spring.a.position )
		add_vertex( spring.b.position )
		
		# End drawing.
		end()

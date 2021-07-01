extends ImmediateGeometry


onready var floater := owner


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	$WaterSurface.set_as_toplevel(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _process(_delta):
	
	clear()
	
	begin(Mesh.PRIMITIVE_LINES)
	
	set_color(Color.red)
	
	# Gravity
	add_vertex( Vector3.ZERO )
	add_vertex( (floater.get_gravity() / floater.floater_count) )
	
	
	
	var depth : float = floater.get_water_height() - floater.global_transform.origin.y
	if depth > 0:
		
		# archimede force
		var displacement_multiplier : float = floater.get_displacement_multiplier(depth)
		set_color(Color.blue)
		add_vertex( Vector3.ZERO )
		add_vertex( floater.transform.basis.y * abs(floater.get_gravity().y) * displacement_multiplier )
		
		set_color(Color.yellow)
		add_vertex( floater.transform.origin.inverse() )
		add_vertex(floater.transform.origin.inverse() + displacement_multiplier * -floater.rigid_body.linear_velocity * floater.water_drag)
		
		set_color(Color.green)
		add_vertex( floater.transform.origin.inverse() )
		add_vertex( floater.transform.origin.inverse() + displacement_multiplier * -floater.rigid_body.angular_velocity * floater.water_angular_drag )
	
	end()


func _physics_process(_delta):
	
	self.global_transform.origin = floater.global_transform.origin
	
	$WaterSurface.global_transform.origin = Vector3(
		floater.global_transform.origin.x,
		floater.get_water_height(),
		floater.global_transform.origin.z
	)
	

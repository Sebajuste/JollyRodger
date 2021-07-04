extends VBoxContainer


export(NodePath) var ship_path 


onready var ship : AbstractShip setget set_ship


# Called when the node enters the scene tree for the first time.
func _ready():
	
	if ship:
		var err := ship.damage_stats.connect("health_changed", self, "_on_health_changed")
		if err != OK:
			push_error("Cannot connect event to health_changed")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if ship_path:
		ship = get_node(ship_path)
	
	if not ship or ship == null:
		return
	
	$Position/Value.text = str( "x: %d, y: %d, z: %d" % [
		ship.global_transform.origin.x,
		ship.global_transform.origin.y,
		ship.global_transform.origin.z
	] )
	
	var dir := Vector2(ship.global_transform.basis.z.x, ship.global_transform.basis.z.z)
	var angle := rad2deg( dir.angle() )
	if angle < 0:
		angle = 360 - abs(angle)
	$Direction/Value.text = str( angle )
	
	var speed := Vector2(ship.linear_velocity.x, ship.linear_velocity.z)
	$Speed/Value.text = str( speed.length() )
	
	$Health/Value.text = str(ship.damage_stats.health)
	


func set_ship(value):
	
	if ship:
		ship.damage_stats.disconnect("health_changed", self, "_on_health_changed")
	
	ship = value
	


func _on_health_changed(value):
	
	$Health/Value.text = str(value)
	



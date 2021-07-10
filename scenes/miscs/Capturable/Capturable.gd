extends Node


signal faction_changed(new_faction, old_faction)
signal contested()
signal uncontested()


var faction : String = "" setget set_faction

var contested := false setget set_contested


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_faction(value):
	if faction != value:
		var old_faction = faction
		faction = value
		print("[%s] New faction : %s" % [owner.name, value])
		emit_signal("faction_changed", value, old_faction)


func set_contested(value):
	
	if contested != value:
		contested = value
		if contested:
			emit_signal("contested")
		else:
			emit_signal("uncontested")
	
	
	

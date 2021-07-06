extends Node


signal faction_changed(new_faction, old_faction)


var faction : String = "" setget set_faction

var contested := false


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
		emit_signal("faction_changed", value, old_faction)

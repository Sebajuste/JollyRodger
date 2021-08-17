extends Control


var CANNON_ITEM_STATUS_SCENE = preload("CannonItemStatus.tscn")



export(NodePath) var ship_path


onready var status_list = $VBoxContainer


#var ship : AbstractShip setget set_ship
var ship_ref = weakref(null)


# Called when the node enters the scene tree for the first time.
func _ready():
	if ship_path:
		set_ship( get_node(ship_path) )


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_ship(_ship : AbstractShip):
	var ship : AbstractShip = ship_ref.get_ref()
	if ship:
		ship.cannons.disconnect("cannon_added", self, "_on_cannon_added")
		ship.cannons.disconnect("cannon_removed", self, "_on_cannon_removed")
	for child in status_list.get_children():
		child.queue_free()
	ship = _ship
	ship_ref = weakref( ship )
	if ship:
		for cannon in ship.cannons.cannons:
			var cannon_item = CANNON_ITEM_STATUS_SCENE.instance()
			status_list.add_child(cannon_item)
			cannon_item.set_cannon( cannon )
		ship.cannons.connect("cannon_added", self, "_on_cannon_added")
		ship.cannons.connect("cannon_removed", self, "_on_cannon_removed")


func _on_cannon_added(cannon):
	var cannon_item = CANNON_ITEM_STATUS_SCENE.instance()
	status_list.add_child(cannon_item)
	cannon_item.set_cannon( cannon )


func _on_cannon_removed(cannon):
	for child in status_list.get_children():
		if child.cannon == cannon:
			child.queue_free()

extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


onready var player := $Player


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var cannon := GameTable.get_item(100001)
	for _i in range(4):
		player.equipment.add_item_in_free_slot({
				"item_id": cannon.id,
				"item_rariry": "Common",
				"quantity": 1,
				"attributes": cannon.attributes
			}
		)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

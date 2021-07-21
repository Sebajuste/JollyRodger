class_name GameItem
extends Resource


var id : int = 0
var category : String
var type : String
var name : String
var description : String
var icon : Texture
var attributes : Dictionary = {}



# Called when the node enters the scene tree for the first time.
func _init( item : Dictionary ):
	
	for key in item:
		
		if item[key] != "":
			match key:
				"id":
					self.id = item.id.to_int()
				"icon":
					self.icon = load(item.icon)
				"category":
					self.category = item.category
				"type":
					self.type = item.type
				"name":
					self.name = item.name
				"description":
					self.description = item.description
				_:
					var value = item[key]
					if self.has_meta(key):
						self.set_meta(key, value)
					else:
						attributes[key] = value
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func to_json() -> String:
	
	return to_json({
		"id": id,
		"name": name,
		"description": description,
		"icon": icon,
		"attributes": attributes
	})
	

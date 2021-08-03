class_name GameItem
extends Resource

enum ATTRIBUT_TYPE {FLOAT, INTEGER, STRING}

const ATTRIBUTS_TYPE := {
	"speed": ATTRIBUT_TYPE.FLOAT,
	"damage": ATTRIBUT_TYPE.INTEGER
}

var id : int = 0
var category : String
var type : String
var name : String
var description : String
var icon : Texture
var max_stack : int
var attributes : Dictionary = {}



# Called when the node enters the scene tree for the first time.
func _init( item : Dictionary ):
	
	self.max_stack = 1
	
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
				"max_stack":
					self.max_stack = item.max_stack.to_int()
				_:
					var value = item[key]
					if self.has_meta(key):
						self.set_meta(key, value)
					else:
						attributes[key] = get_attribute(key, value)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_attribute(key, value):
	
	if ATTRIBUTS_TYPE.has(key):
		
		match ATTRIBUTS_TYPE[key]:
			ATTRIBUT_TYPE.FLOAT:
				return value.to_float()
			ATTRIBUT_TYPE.INTEGER:
				return value.to_int()
			ATTRIBUT_TYPE.STRING:
				return str(value)
			_:
				return value
		
	else:
		return value
	


func to_json() -> String:
	
	return to_json({
		"id": id,
		"name": name,
		"description": description,
		"icon": icon,
		"attributes": attributes
	})
	

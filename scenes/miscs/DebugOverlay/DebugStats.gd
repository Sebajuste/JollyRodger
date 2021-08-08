extends MarginContainer



class Property:
	var label
	var object
	var property
	var display
	
	func _init(_label: Label, _object : Object, _property : String, _display : String):
		label = _label
		object = _object
		property = _property
		display = _display
	
	func set_label():
		var s := "%s/%s : " % [object.name, property]
		
		var properties = property.split(":")
		
		var p = object.get_indexed(properties[0])
		for i in range(1, len(properties) ):
			match typeof(p):
				TYPE_ARRAY:
					p = p[int(properties[i])]
				_:
					p = p[properties[i]]
		
		
		#var p = object.get_indexed(property)
		
		match display:
			"length":
				s += "%4.2f" % p
			"round":
				match typeof(p):
					TYPE_INT, TYPE_REAL:
						s += "%4.2f" % p
					TYPE_VECTOR2, TYPE_VECTOR3:
						s += str(p.round())
					_:
						s += str(p)
			"", _:
				s += str(p)
		
		label.text = s


onready var property_list := $VBoxContainer

var properties := []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		for property in properties:
			property.set_label()


func add_property(object : Object, property : String, display := ""):
	
	var label = Label.new()
	
	property_list.add_child(label)
	
	properties.append( Property.new(label, object, property, display) )
	
	pass


func remove_property():
	
	pass

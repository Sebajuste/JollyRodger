extends StaticBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


onready var high_model := $"Skin/MeshInstance-lod0"
onready var medium_model := $"Skin/MeshInstance-lod1"
onready var low_model := $"Skin/MeshInstance-lod2"
onready var low_shadow := $"Skin/MeshInstance-shadow-lod2"
onready var long_distance_model := $"Skin/MeshInstance-lod3"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var _r := Configuration.connect("configuration_changed", self, "_on_configuration_changed")
	
	update_trees(Configuration.Settings.Display.Trees)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func update_trees(detail_level : String):
	print("detail_level : ", detail_level)
	match detail_level:
		"ultra":
			high_model.name = "MeshInstance-lod0"
			medium_model.name = "MeshInstance-lod1"
			low_model.name = "MeshInstance-lod2"
			low_shadow.name = "MeshInstance-shadow-lod2"
			long_distance_model.name = "MeshInstance-lod3"
		"high":
			long_distance_model.name = "MeshInstance-lod3-disable"
			high_model.name = "MeshInstance-lod0"
			medium_model.name = "MeshInstance-lod1"
			low_model.name = "MeshInstance-lod2"
			low_shadow.name = "MeshInstance-shadow-lod2"
		"medium":
			long_distance_model.name = "MeshInstance-lod3-disable"
			low_model.name = "MeshInstance-lod2-disable"
			low_shadow.name = "MeshInstance-shadow-lod2-disable"
			high_model.name = "MeshInstance-lod0"
			medium_model.name = "MeshInstance-lod1"
		_, "low":
			high_model.name = "MeshInstance-lod0-disable"
			medium_model.name = "MeshInstance-lod1-disable"
			low_shadow.name = "MeshInstance-shadow-disable"
			long_distance_model.name = "MeshInstance-lod3-disable"
			low_model.name = "MeshInstance-lod0"
	



func _on_configuration_changed(config):
	
	update_trees(config.Display.Trees)
	

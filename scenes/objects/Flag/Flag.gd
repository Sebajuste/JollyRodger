class_name ShipFlag
extends Spatial


#const FLAG_MATERIAL := preload("flag.material")


var MATERIAL_MAP := {
	"None": "",
	"GB": "res://scenes/objects/Flag/flag_gb.material",
	"Pirate": "res://scenes/objects/Flag/flag_pirate.material"
}


export(String, "None", "GB", "Pirate") var type := "None" setget set_type


onready var flag_mesh := $Pivot/MeshInstance


# Called when the node enters the scene tree for the first time.
func _ready():
	
	#set_network_master( owner.get_network_master() )
	
	set_type(type)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func load_material():
	if flag_mesh and type != null and MATERIAL_MAP.has(type):
		var material_path : String = MATERIAL_MAP[type]
		if material_path != "":
			var material : Material = load(material_path)
			if material:
				flag_mesh.set_surface_material(0, material)


func set_type(value):
	type = value
	if flag_mesh:
		load_material()
		if Network.enabled and is_network_master():
			rpc("rpc_change_flag", value)


puppet func rpc_change_flag(value):
	type = value
	load_material()


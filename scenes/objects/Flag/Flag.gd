class_name ShipFlag
extends Spatial


var MATERIAL_MAP := {
	"None": "",
	"GB": "res://scenes/objects/Flag/flag_gb.material",
	"Pirate": "res://scenes/objects/Flag/flag_pirate.material"
}


export(String, "None", "GB", "Pirate") var faction := "None" setget set_faction


onready var flag_mesh := $Pivot/MeshInstance


# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_faction(faction)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func load_material():
	if flag_mesh and faction != "None" and MATERIAL_MAP.has(faction):
		var material_path : String = MATERIAL_MAP[faction]
		var material : Material = load(material_path)
		if material:
			print("Load material for %s : %s" % [owner.name, faction])
			flag_mesh.set_surface_material(0, material)


func set_faction(value):
	faction = value
	if flag_mesh:
		load_material()
		if Network.enabled and is_network_master():
			rpc("rpc_change_flag", value)


func _on_Flag_tree_entered():
	if Network.enabled and not is_network_master():
		rpc("rpc_request_flag")


puppet func rpc_change_flag(value):
	faction = value
	load_material()


master func rpc_request_flag():
	var peer_id := get_tree().get_rpc_sender_id()
	rpc_id(peer_id, "rpc_change_flag", faction)
	


func _on_Capturable_faction_changed(new_faction, old_faction):
	
	set_faction(new_faction)
	

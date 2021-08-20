class_name ShipFlag
extends Spatial

"""
var MATERIAL_MAP := {
	"None": "",
	"GB": "res://scenes/objects/Flag/flag_gb.material",
	"Spain": "res://scenes/objects/Flag/flag_spain.material",
	"Pirate": "res://scenes/objects/Flag/flag_pirate.material"
}
"""

const TEXTURE_MAP := {
	"None": "",
	"GB": "res://assets/2d/textures/flag_united_kingdom.png",
	"Spain": "res://assets/2d/textures/flag_spain.png",
	"Pirate": "res://assets/2d/textures/black_flag.png"
}


export(String, "None", "GB", "Spain", "Pirate") var faction := "None" setget set_faction


# onready var flag_mesh := $Pivot/MeshInstance
onready var flag_texture := $Pivot/Viewport/FlagTexture


# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_faction(faction)
	
	pass # Replace with function body.

"""
func _enter_tree():
	if Network.enabled and not is_network_master():
		rpc("rpc_request_flag")
"""

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func load_texture():
	
	if flag_texture and faction != "None" and TEXTURE_MAP.has(faction):
		var texture_path : String = TEXTURE_MAP[faction]
		var texture : Texture = load(texture_path)
		if texture:
			#print("Load texture for %s : %s" % [owner.name, faction])
			flag_texture.texture = texture
		
		pass
	
	"""
	if flag_mesh and faction != "None" and MATERIAL_MAP.has(faction):
		var material_path : String = MATERIAL_MAP[faction]
		var material : Material = load(material_path)
		if material:
			print("Load material for %s : %s" % [owner.name, faction])
			flag_mesh.set_surface_material(0, material)
	"""
	pass


func set_faction(value):
	faction = value
	load_texture()
	"""
	if flag_mesh:
		load_material()
		
		if Network.enabled and is_network_master():
			rpc("rpc_change_flag", value)
	"""

"""
puppet func rpc_change_flag(value):
	faction = value
	load_material()


master func rpc_request_flag():
	var peer_id := get_tree().get_rpc_sender_id()
	rpc_id(peer_id, "rpc_change_flag", faction)
	
"""

func _on_Capturable_faction_changed(new_faction, _old_faction):
	
	set_faction(new_faction)
	

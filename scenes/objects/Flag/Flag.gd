class_name ShipFlag
extends Spatial


const TEXTURE_MAP := {
	"None": "",
	"GB": "res://assets/2d/textures/flag_united_kingdom.png",
	"Spain": "res://assets/2d/textures/flag_spain.png",
	"Pirate": "res://assets/2d/textures/black_flag.png"
}


export(String, "None", "GB", "Spain", "Pirate") var faction := "None" setget set_faction


onready var flag_texture := $Pivot/Viewport/FlagTexture


# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_faction(faction)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func load_texture():
	
	if flag_texture and faction != "None" and TEXTURE_MAP.has(faction):
		var texture_path : String = TEXTURE_MAP[faction]
		var texture : Texture = load(texture_path)
		if texture:
			flag_texture.texture = texture


func set_faction(value):
	faction = value
	load_texture()


func _on_Capturable_faction_changed(new_faction, _old_faction):
	
	set_faction(new_faction)
	

tool
extends Spatial

const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")
const HTerrainDetailLayer = preload("res://addons/zylann.hterrain/hterrain_detail_layer.gd")

export(int) var layer_index := 0
export(Texture) var texture : Texture
export(Mesh) var instance_mesh : Mesh
export(float, 1.0, 500.0) var view_distance := 500.0
export(Shader) var custom_shader : Shader
export(float, 0, 10) var density := 4.0
export(float) var min_height_threshold := 0
export(float) var max_height_threshold := 1000
export(float, 0.0, 1.0) var amount_on_slope := 0.0
export(float, 0.0, 1.0) var amount_on_flat := 1.0

var _map : Image

func _ready():
	pass 

func generate_detail_layer(terrain_data : HTerrainData) -> HTerrainDetailLayer:
	terrain_data._edit_add_map(terrain_data.CHANNEL_DETAIL)
	var detail = HTerrainDetailLayer.new()
	detail.set_layer_index(layer_index)
	detail.set_texture(texture)
	detail.set_instance_mesh(instance_mesh)
	detail.set_view_distance(view_distance)
	detail.set_custom_shader(custom_shader)
	detail.set_density(density)
	return detail


func lock_map(terrain_data : HTerrainData):
	_map = terrain_data.get_image(HTerrainData.CHANNEL_DETAIL, layer_index)
	_map.lock()
	pass

func unlock_map():
	_map.unlock()
	pass

func set_on_map(x : float, y : float, slope : float, hight : float):
	var amount : float = 1.0
	if hight < min_height_threshold or hight > max_height_threshold:
		amount = 0.0
	else:
		amount = clamp((1.0 - slope) * amount_on_slope, 0.0, 1.0)
		amount = clamp(amount + slope * amount_on_flat, 0.0, 1.0)
		#amount = clamp(slope * amount_on_flat, 0.0, 1.0)
		#amount = clamp((1.0 - slope) * amount_on_slope, 0.0, 1.0)
	
	_map.set_pixel(x, y, Color(amount, 0, 0, 0))
	pass

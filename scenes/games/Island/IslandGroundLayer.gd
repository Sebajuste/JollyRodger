tool
extends "res://scenes/games/Island/IslandLayerAmount.gd"

const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")
const HTerrainTextureSet = preload("res://addons/zylann.hterrain/hterrain_texture_set.gd")

export(Texture) var texture


var _layer_index : int = 0

func set_texture(texture_set : HTerrainTextureSet, index : int):
	_layer_index = index
	texture_set.insert_slot(-1)
	texture_set.set_texture(_layer_index, HTerrainTextureSet.TYPE_ALBEDO_BUMP, texture)
	pass

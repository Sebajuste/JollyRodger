tool
extends Spatial

# Import classes
const HTerrain = preload("res://addons/zylann.hterrain/hterrain.gd")
const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")
const HTerrainTextureSet = preload("res://addons/zylann.hterrain/hterrain_texture_set.gd")
const HTerrainDetailLayer = preload("res://addons/zylann.hterrain/hterrain_detail_layer.gd")
const IslandGroundLayer = preload("res://scenes/games/Island/IslandGroundLayer.gd")
const IslandDetailLayer = preload("res://scenes/games/Island/IslandDetailLayer.gd")

export(float, 0.0, 1.0) var ambient_wind := 0.4
export(int, 2, 5) var lod_scale := 2.0
export(OpenSimplexNoise) var noise : OpenSimplexNoise
export(Curve) var height_curve : Curve
export(Curve) var island_curve : Curve
export(float) var island_height = 150
export(float) var terrain_size = 256
export(int) var chunk_width = 1
export(int) var chunk_id = -1
export(float) var border_size : float = 30
export(float, 0, 1000) var underwater_depth : float = 1000
export(Shader) var custom_shader : Shader = null

var _island_size := 0

export(bool) var refresh := true
func _ready():
	if Engine.editor_hint:
		refresh = true
	else:
		generate_island()
	pass


func _process(delta):
	if Engine.editor_hint:
		if refresh:
			delete_old_terrain()
			refresh = false
			generate_island()
			print("end")


func generate_island():
	_island_size = terrain_size * chunk_width - border_size
	print("starting generation, island size => " + str(_island_size))
	if chunk_id < 0:
		for id in chunk_width * chunk_width:
			generate_chunk_id(id)
	elif chunk_id >= chunk_width * chunk_width:
		print("chunk id out of map")
	else:
		generate_chunk_id(chunk_id)


func generate_chunk_id(id : int):
	var col = 0
	var row = 0
	if chunk_width > 1:
		col = id % chunk_width
		row = id / chunk_width
	
	var space = terrain_size #- 0.1 * chunk_width
	var offset = Vector2(col * space, row * space)
	var terrain_data : HTerrainData = HTerrainData.new()
	terrain_data.resize(terrain_size)
	
	var detail_layers := generate_detail_layers(terrain_data)
	generate_map_data(terrain_data, offset)
	generate_terrain(terrain_data, detail_layers, offset)
	pass

func generate_detail_layers(terrain_data : HTerrainData) -> Array:
	var layers : Array = Array()
	var index : int = 0
	for child in get_children():
		if child is IslandDetailLayer:
			layers.append(child.generate_detail_layer(terrain_data, index))
			index += 1
			pass
	return layers

func generate_map_data(terrain_data : HTerrainData, offset : Vector2 = Vector2.ZERO):
	var heightMap: Image = terrain_data.get_image(HTerrainData.CHANNEL_HEIGHT)
	var normalMap: Image = terrain_data.get_image(HTerrainData.CHANNEL_NORMAL)
	var splatMap: Image = terrain_data.get_image(HTerrainData.CHANNEL_SPLAT)
	
	var center = Vector2((terrain_size  * chunk_width) / 2, (terrain_size  * chunk_width) / 2)
	
	heightMap.lock()
	normalMap.lock()
	splatMap.lock()
	for child in get_children():
		if child is IslandDetailLayer:
			child.lock_map(terrain_data)
			pass
	
	for z in terrain_size + 1:
		for x in terrain_size + 1:
			# Generate height
			var v : Vector2 = Vector2(offset.x + x, offset.y + z) 
			var h = generate_height(v.x, v.y, center)
			
			# Getting normal by generating extra heights directly from noise,
			var h_right = generate_height(v.x + 0.1, v.y, center)
			var h_forward = generate_height(v.x, v.y + 0.1, center)
			var normal = Vector3(h - h_right, 0.1, h_forward - h).normalized()
			
			# Generate texture amounts
			var splat : Color = splatMap.get_pixel(x, z)
			var slope = 5.0 * normal.dot(Vector3.UP) - 2.0
			
			heightMap.set_pixel(x, z, Color(h, 0, 0))
			normalMap.set_pixel(x, z, HTerrainData.encode_normal(normal))
			
			var color := Color(1,0,0,0)
			for child in get_children():
				if child is IslandGroundLayer:
					splat = splat.linear_interpolate(color, child.get_amount(slope, h))
					color = shift_right(color)
					pass
				elif child is IslandDetailLayer:
					child.set_on_map(x, z, slope, h)
					pass
			splatMap.set_pixel(x, z, splat)

	heightMap.unlock()
	normalMap.unlock()
	splatMap.unlock()
	var detail_layer_changed : bool = false
	for child in get_children():
		if child is IslandDetailLayer:
			child.unlock_map()
			detail_layer_changed = true
			pass
	
	var modified_region = Rect2(Vector2.ZERO, heightMap.get_size())
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_NORMAL)
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_SPLAT)
	if detail_layer_changed:
		terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_DETAIL)
	pass

func shift_right(c : Color) -> Color:
	return Color(0, c.r, c.g, c.b)

func generate_terrain(terrain_data : HTerrainData, childs : Array, offset : Vector2 = Vector2.ZERO):
	var terrain = HTerrain.new()
	terrain.set_ambient_wind(ambient_wind)
	terrain.set_lod_scale(lod_scale)
	terrain.set_shader_type(HTerrain.SHADER_CLASSIC4_LITE)
	terrain.set_custom_shader(custom_shader)
	terrain.set_data(terrain_data)
	var texture_set : HTerrainTextureSet = generate_texture_set()
	terrain.set_texture_set(texture_set)
	terrain.set_translation(Vector3(offset.x, 0, offset.y))
	add_child(terrain)
	for c in childs:
		terrain.add_child(c)
	pass


func generate_texture_set() -> HTerrainTextureSet:
	var texture_set = HTerrainTextureSet.new()
	texture_set.set_mode(HTerrainTextureSet.MODE_TEXTURES)
	var index : int = 0
	for child in get_children():
		if child is IslandGroundLayer:
			child.set_texture(texture_set, index)
			index += 1
			pass
	return texture_set


func generate_height(x : float, z : float, center : Vector2) -> float :
	var h = (noise.get_noise_2d(x, z) + 1) * 0.5
	return height_curve.interpolate(h) * get_island_factor(x, z, center)


func get_island_factor(x : float, z : float, center : Vector2) -> float :
	var distance := Vector2(x, z).distance_to(center) * 2.0
	var curve_position := distance / _island_size
	
	if curve_position < 1: # On the island
		return island_curve.interpolate(1.0 - curve_position) * island_height
	else:
		var border_position := distance / (_island_size + border_size)
		if border_position < 1: # On the border (beach)
			return curve_position - border_position# * island_height
		else:	# Out of the island, on the sea
			return -island_curve.interpolate(border_position - 1.0) * underwater_depth


func delete_old_terrain():
	for child in get_children():
		if child is HTerrain:
			child.queue_free()
	pass

func _get_configuration_warning():
	var g : int = 0
	var d : int = 0
	for child in get_children():
		if child is IslandGroundLayer:
			g += 1
			pass
		elif child is IslandDetailLayer:
			d += 1
			pass
	if g > 4:
		return "The number of ground layer is limited to 4 !"
	
	if chunk_id >= chunk_width * chunk_width:
		return "chunk id out of map"
	
	return ""

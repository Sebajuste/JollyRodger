tool
extends Spatial



# Import classes
const HTerrain = preload("res://addons/zylann.hterrain/hterrain.gd")
const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")
const HTerrainTextureSet = preload("res://addons/zylann.hterrain/hterrain_texture_set.gd")
const HTerrainDetailLayer = preload("res://addons/zylann.hterrain/hterrain_detail_layer.gd")
const IslandDetailLayer = preload("res://scenes/games/Island/IslandDetailLayer.gd")

export(float, 0.0, 1.0) var ambient_wind := 0.4
export(int, 2, 5) var lod_scale := 2.0
#export(Shader) var detail_shader
#export(Shader) var palm_shader
export(OpenSimplexNoise) var noise :OpenSimplexNoise
export(Curve) var height_curve : Curve
export(Curve) var island_curve : Curve
#export(float) var grass_density = 4
#export(float) var flower_density = 1
#export(float) var palm_density = 0.04
#export(float, 0, 1) var grass_on_sand = 0.6
#export(float, 0, 1) var grass_on_rock = 0.5
export(float) var island_height = 150
export(float) var sand_level = 5
#export(float) var palms_height_threshold = 2
export(float) var terrain_size = 64
export(int) var chunk_width = 3

var island_size : float = terrain_size * chunk_width / 2.8
var beach_size : float = terrain_size * chunk_width / 2.5

var grass_texture = load("res://assets/2d/textures/terrain/TexturesCom_Grass0157_1_seamless_S.jpg")
var sand_texture = load("res://assets/2d/textures/terrain/Sand_007_basecolor.jpg")
var rock_texture = load("res://assets/2d/textures/terrain/TexturesCom_CliffRock_A_2x2_1K_albedo.jpg")
var grass_detail = load("res://assets/2d/textures/grass.png")
var flower_detail = load("res://assets/2d/textures/grass2.png")

var _custom_shader : Shader = null
var _custom_globalmap_shader : Shader = null
var _texture_set := HTerrainTextureSet.new()

func _ready():
#func _process(delta):
	print("starting generation")
	# Create terrain resource and give it a size.
	# It must be either 513, 1025, 2049 or 4097.
	var space : float = (terrain_size - chunk_width - 1)
	for i in (chunk_width * chunk_width):
		var col = 0
		var row = 0
		if chunk_width > 1:
			col = i % chunk_width
			row = i / chunk_width
			
		var offset = Vector2(col * space, row * space)
		var terrain_data : HTerrainData = HTerrainData.new()
		terrain_data.resize(terrain_size)
		
		var terrain_childs := Array()
		
		for child in get_children():
			if child is IslandDetailLayer:
				terrain_childs.append(child.generate_detail_layer(terrain_data))
				pass
		
		generate_map(terrain_data, offset)
		generate_terrain(terrain_data, terrain_childs, offset)
		pass
	print("ending generation")


func generate_map(terrain_data : HTerrainData, offset : Vector2 = Vector2.ZERO):
	var heightMap: Image = terrain_data.get_image(HTerrainData.CHANNEL_HEIGHT)
	var normalMap: Image = terrain_data.get_image(HTerrainData.CHANNEL_NORMAL)
	var splatMap: Image = terrain_data.get_image(HTerrainData.CHANNEL_SPLAT)
	
	var center = Vector2((terrain_size  * chunk_width) / 2, (terrain_size  * chunk_width) / 2)
#	var grass_prct_sand = 1 - grass_on_sand
#	var grass_prct_rock = 1 - grass_on_rock
	
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
			
			var sand_amount : float = clamp(1 - slope + sand_level - h, 0.0, 1.0)
			var rock_amount : float = clamp(1.0 - slope, 0.0, 1.0)
			
#			var grass_amount : float = clamp(1 - rock_amount * grass_prct_rock - sand_amount * grass_prct_sand, 0, 1)
#			var flower_amount : float = clamp(1 - rock_amount - sand_amount, 0, 1)
#			var palm_amount : float = clamp(h - palms_height_threshold, 0, 1)
#			palm_amount = clamp(palm_amount - rock_amount, 0, 1)
			
			splat = splat.linear_interpolate(Color(0,1,0,0), sand_amount)
			splat = splat.linear_interpolate(Color(0,0,1,0), rock_amount)
			
			heightMap.set_pixel(x, z, Color(h, 0, 0))
			normalMap.set_pixel(x, z, HTerrainData.encode_normal(normal))
			splatMap.set_pixel(x, z, splat)
			for child in get_children():
				if child is IslandDetailLayer:
					child.set_on_map(x, z, slope, h)
					pass

	heightMap.unlock()
	normalMap.unlock()
	splatMap.unlock()
	for child in get_children():
		if child is IslandDetailLayer:
			child.unlock_map()
			pass
	
	var modified_region = Rect2(Vector2.ZERO, heightMap.get_size())
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_NORMAL)
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_SPLAT)
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_DETAIL)
	pass

func shift_right(c : Color) -> Color:
	return Color(0, c.r, c.g, c.b)

func generate_terrain(terrain_data : HTerrainData, childs : Array, offset : Vector2 = Vector2.ZERO):
	var terrain = HTerrain.new()
	for c in childs:
		terrain.add_child(c)
	
	terrain.set_ambient_wind(ambient_wind)
	terrain.set_lod_scale(lod_scale)
	terrain.set_shader_type(HTerrain.SHADER_CLASSIC4_LITE)
	terrain.set_data(terrain_data)
	generate_texture_set()
	terrain.set_texture_set(_texture_set)
	terrain.set_translation(Vector3(offset.x, 0, offset.y))
	add_child(terrain)
	pass


func generate_texture_set():
	var texture_set = HTerrainTextureSet.new()
	texture_set.set_mode(HTerrainTextureSet.MODE_TEXTURES)
	texture_set.insert_slot(-1)
	texture_set.set_texture(0, HTerrainTextureSet.TYPE_ALBEDO_BUMP, grass_texture)
	texture_set.insert_slot(-1)
	texture_set.set_texture(1, HTerrainTextureSet.TYPE_ALBEDO_BUMP, sand_texture)
	texture_set.insert_slot(-1)
	texture_set.set_texture(2, HTerrainTextureSet.TYPE_ALBEDO_BUMP, rock_texture)
	set_texture_set(texture_set)


func generate_detail_layer_texture(terrain_data : HTerrainData, texture : Texture, density : float, shader : Shader, index : int = 0) -> HTerrainDetailLayer :
	terrain_data._edit_add_map(terrain_data.CHANNEL_DETAIL)
	var detail = HTerrainDetailLayer.new()
	detail.set_texture(texture)
	detail.set_custom_shader(shader)
	detail.set_view_distance(500)
	detail.set_density(density)
	detail.set_layer_index(index)
	return detail


func generate_detail_layer_mesh(terrain_data : HTerrainData, mesh : Mesh, density : float, shader : Shader, index : int = 0) -> HTerrainDetailLayer :
	terrain_data._edit_add_map(terrain_data.CHANNEL_DETAIL)
	var detail = HTerrainDetailLayer.new()
	detail.set_instance_mesh(mesh)
	detail.set_custom_shader(shader)
	detail.set_view_distance(500)
	detail.set_density(density)
	detail.set_layer_index(index)
	return detail


func generate_height(x : float, z : float, center : Vector2) -> float :
	var h = (noise.get_noise_2d(x, z) + 1) * 0.5
	return height_curve.interpolate(h) * generate_island_factor(x, z, center)


func generate_island_factor(x : float, z : float, center : Vector2) -> float :
	var distance := Vector2(x, z).distance_to(center)
	var curve_position := distance / island_size
	var beach_position := distance / beach_size
	
	if beach_position > 1:
		return -island_curve.interpolate(beach_position - 1.0) * island_height
	else:
		if curve_position > 1:
			return curve_position - beach_position# * island_height
		else:
			return island_curve.interpolate(1.0 - curve_position) * island_height


func get_palm() -> Mesh:
	var mesh : CylinderMesh = CylinderMesh.new()
	mesh.set_height(10)
	mesh.set_bottom_radius(0.133)
	mesh.set_top_radius(0.133)
	return mesh
	
# No need to call this, but you may need to if you edit the terrain later on
#terrain.update_collider()

func _get_property_list():
	var props = [
		{
			"name": "Shader",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_GROUP
		},
		{
			"name": "custom_shader",
			"type": TYPE_OBJECT,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "Shader"
		},
		{
			"name": "custom_globalmap_shader",
			"type": TYPE_OBJECT,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "Shader"
		},
		{
			"name": "texture_set",
			"type": TYPE_OBJECT,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "Resource"
		}
	]
	return props


func _get(key: String):
	if key == "texture_set":
		return get_texture_set()
	elif key == "custom_shader":
		return get_custom_shader()
	elif key == "custom_globalmap_shader":
		return _custom_globalmap_shader

func _set(key: String, value):
	if key == "texture_set":
		set_texture_set(value)
	elif key == "custom_shader":
		set_custom_shader(value)
	elif key == "custom_globalmap_shader":
		_custom_globalmap_shader = value


func get_texture_set() -> HTerrainTextureSet:
	return _texture_set

func set_texture_set(new_set: HTerrainTextureSet):
	_texture_set = new_set


func get_custom_shader() -> Shader:
	return _custom_shader

func set_custom_shader(shader: Shader):
	_custom_shader = shader

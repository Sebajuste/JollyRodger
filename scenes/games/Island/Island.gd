extends Node

# Import classes
const HTerrain = preload("res://addons/zylann.hterrain/hterrain.gd")
const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")
const HTerrainTextureSet = preload("res://addons/zylann.hterrain/hterrain_texture_set.gd")
const HTerrainDetailLayer = preload("res://addons/zylann.hterrain/hterrain_detail_layer.gd")

export(Shader) var detail_shader
export(Shader) var palm_shader
export(OpenSimplexNoise) var noise
export(OpenSimplexNoise) var models_noise
export(Curve) var height_curve : Curve
export(Curve) var island_curve : Curve
export(float) var wind = 0.4
export(float) var grass_density = 4
export(float) var flower_density = 1
export(float) var palm_density = 0.04
export(float, 0, 1) var grass_on_sand = 0.6
export(float, 0, 1) var grass_on_rock = 0.5
export(float) var island_height = 150
export(float) var sand_level = 5
export(float) var terrain_size = 513
export(float) var palms_height_threshold = 2

var island_size : float = terrain_size / 2.3
var beach_size : float = terrain_size / 2

var grass_texture = load("res://assets/2d/textures/terrain/TexturesCom_Grass0157_1_seamless_S.jpg")
var sand_texture = load("res://assets/2d/textures/terrain/Sand_007_basecolor.jpg")
var rock_texture = load("res://assets/2d/textures/terrain/TexturesCom_CliffRock_A_2x2_1K_albedo.jpg")
var grass_detail = load("res://assets/2d/textures/grass.png")
var flower_detail = load("res://assets/2d/textures/grass2.png")

func _ready():
	# Create terrain resource and give it a size.
	# It must be either 513, 1025, 2049 or 4097.
	var terrain_data : HTerrainData = HTerrainData.new()
	terrain_data.resize(terrain_size)
	
	var terrain_childs := Array()
	
	# Generate grass, flower and palms detail layer
	terrain_childs.append(generate_detail_layer_texture(terrain_data, grass_detail, grass_density, detail_shader, 0))
	terrain_childs.append(generate_detail_layer_texture(terrain_data, flower_detail, flower_density, detail_shader, 1))
	terrain_childs.append(generate_detail_layer_mesh(terrain_data, get_palm(), palm_density, palm_shader, 2))
	
	# Commit modifications so they get uploaded to the graphics card
	generate_map(terrain_data)
	generate_terrain(terrain_data, terrain_childs)
	pass


func generate_map(terrain_data : HTerrainData):
	var heightMap: Image = terrain_data.get_image(HTerrainData.CHANNEL_HEIGHT)
	var normalMap: Image = terrain_data.get_image(HTerrainData.CHANNEL_NORMAL)
	var splatMap: Image = terrain_data.get_image(HTerrainData.CHANNEL_SPLAT)
	var grassMap: Image = terrain_data.get_image(HTerrainData.CHANNEL_DETAIL, 0)
	var flowerMap: Image = terrain_data.get_image(HTerrainData.CHANNEL_DETAIL, 1)
	var palmMap: Image = terrain_data.get_image(HTerrainData.CHANNEL_DETAIL, 2)
	
	var center = Vector2(heightMap.get_width() / 2, heightMap.get_height() / 2)
	var grass_prct_sand = 1 - grass_on_sand
	var grass_prct_rock = 1 - grass_on_rock
	
	heightMap.lock()
	normalMap.lock()
	splatMap.lock()
	grassMap.lock()
	flowerMap.lock()
	palmMap.lock()
	
	for z in heightMap.get_height():
		for x in heightMap.get_width():
			# Generate height
			var h = generate_height(x, z, center)
			
			# Getting normal by generating extra heights directly from noise,
			var h_right = generate_height(x + 0.1, z, center)
			var h_forward = generate_height(x, z + 0.1, center)
			var normal = Vector3(h - h_right, 0.1, h_forward - h).normalized()
			
			# Generate texture amounts
			var splat : Color = splatMap.get_pixel(x, z)
			var slope = 5.0 * normal.dot(Vector3.UP) - 2.0
			
			var sand_amount : float = clamp(1 - slope + sand_level - h, 0.0, 1.0)
			var rock_amount : float = clamp(1.0 - slope, 0.0, 1.0)
			var grass_amount : float = clamp(1 - rock_amount * grass_prct_rock - sand_amount * grass_prct_sand, 0, 1)
			var flower_amount : float = clamp(1 - rock_amount - sand_amount, 0, 1)
			var palm_amount : float = clamp(h - palms_height_threshold, 0, 1)
			palm_amount = clamp(palm_amount - rock_amount, 0, 1)
			
			splat = splat.linear_interpolate(Color(0,1,0,0), sand_amount)
			splat = splat.linear_interpolate(Color(0,0,1,0), rock_amount)
			
			heightMap.set_pixel(x, z, Color(h, 0, 0))
			normalMap.set_pixel(x, z, HTerrainData.encode_normal(normal))
			splatMap.set_pixel(x, z, splat)
			grassMap.set_pixel(x, z, Color(grass_amount,0,0,0))
			flowerMap.set_pixel(x, z, Color(flower_amount,0,0,0))
			palmMap.set_pixel(x, z, Color(palm_amount,0,0,0))

	heightMap.unlock()
	normalMap.unlock()
	splatMap.unlock()
	grassMap.unlock()
	flowerMap.unlock()
	palmMap.unlock()
	
	var modified_region = Rect2(Vector2.ZERO, heightMap.get_size())
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_NORMAL)
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_SPLAT)
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_DETAIL)
	pass


func generate_terrain(terrain_data : HTerrainData, childs : Array):
	var terrain = HTerrain.new()
	for c in childs:
		terrain.add_child(c)
	
	terrain.ambient_wind = wind
	terrain.set_shader_type(HTerrain.SHADER_CLASSIC4_LITE)
	terrain.set_data(terrain_data)
	terrain.set_texture_set(generate_texture_set())
	add_child(terrain)
	pass


func generate_texture_set() -> HTerrainTextureSet:
	var texture_set = HTerrainTextureSet.new()
	texture_set.set_mode(HTerrainTextureSet.MODE_TEXTURES)
	texture_set.insert_slot(-1)
	texture_set.set_texture(0, HTerrainTextureSet.TYPE_ALBEDO_BUMP, grass_texture)
	texture_set.insert_slot(-1)
	texture_set.set_texture(1, HTerrainTextureSet.TYPE_ALBEDO_BUMP, sand_texture)
	texture_set.insert_slot(-1)
	texture_set.set_texture(2, HTerrainTextureSet.TYPE_ALBEDO_BUMP, rock_texture)
	return texture_set


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
		return -island_height
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

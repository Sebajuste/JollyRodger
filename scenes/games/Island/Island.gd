extends Node

# Import classes
const HTerrain = preload("res://addons/zylann.hterrain/hterrain.gd")
const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")
const HTerrainTextureSet = preload("res://addons/zylann.hterrain/hterrain_texture_set.gd")

export(OpenSimplexNoise) var noise
export(OpenSimplexNoise) var flower_noise
export(Curve) var height_curve : Curve
export(float) var island_height = 200.0
export(float) var sand_level = 25
export(float) var terrain_size = 513
var min_center_distance = terrain_size / 4
var max_center_distance = terrain_size / 2
var island_size : float = rand_range(min_center_distance, max_center_distance)
# You may want to change paths to your own textures

var grass_texture = load("res://assets/2d/textures/terrain/TexturesCom_Grass0157_1_seamless_S.jpg")
var sand_texture = load("res://assets/2d/textures/terrain/Sand_007_basecolor.jpg")
var rock_texture = load("res://assets/2d/textures/terrain/TexturesCom_CliffRock_A_2x2_1K_albedo.jpg")
var flower_texture = load("res://assets/2d/textures/terrain/Rocks006_1K-JPG/Rocks006_1K_Color.jpg")

func _ready():
	# Create terrain resource and give it a size.
	# It must be either 513, 1025, 2049 or 4097.
	var terrain_data = HTerrainData.new()
	terrain_data.resize(terrain_size)

	

	# Get access to terrain maps
	var heightmap: Image = terrain_data.get_image(HTerrainData.CHANNEL_HEIGHT)
	var normalmap: Image = terrain_data.get_image(HTerrainData.CHANNEL_NORMAL)
	var splatmap: Image = terrain_data.get_image(HTerrainData.CHANNEL_SPLAT)

	heightmap.lock()
	normalmap.lock()
	splatmap.lock()
	var center = Vector2(heightmap.get_width() / 2, heightmap.get_height() / 2)

	# Generate terrain maps
	# Note: this is an example with some arbitrary formulas,
	# you may want to come up with your owns
	for z in heightmap.get_height():
		for x in heightmap.get_width():
			# Generate height			
			var h = island_height * noise.get_noise_2d(x, z) * get_island_factor(x, z, center)

			# Getting normal by generating extra heights directly from noise,
			# so map borders won't have seams in case you stitch them
			var h_right = island_height * noise.get_noise_2d(x + 0.1, z) * get_island_factor(x + 0.1, z, center)
			var h_forward = island_height * noise.get_noise_2d(x, z + 0.1) * get_island_factor(x, z + 0.1, center)
			var normal = Vector3(h - h_right, 0.1, h_forward - h).normalized()
			
			# Generate texture amounts
			var splat = splatmap.get_pixel(x, z)
			var slope = 5.0 * normal.dot(Vector3.UP) - 2.0
			
			# Sand below sea level
			var sand_amount = clamp(sand_level - h, 0.0, 1.0)
			# Rock on the slopes
			var rock_amount = clamp(1.0 - slope, 0.0, 1.0)
			# Randomly put flowers where there is no rock and no sand
			var flower_amount = clamp(flower_noise.get_noise_2d(x, z) - rock_amount - sand_amount, 0, 1)
			
			splat = splat.linear_interpolate(Color(0,1,0,0), sand_amount)
			splat = splat.linear_interpolate(Color(0,0,1,0), rock_amount)
			splat = splat.linear_interpolate(Color(0,0,0,1), flower_amount)

			heightmap.set_pixel(x, z, Color(h, 0, 0))
			normalmap.set_pixel(x, z, HTerrainData.encode_normal(normal))
			splatmap.set_pixel(x, z, splat)

	heightmap.unlock()
	normalmap.unlock()
	splatmap.unlock()

	# Commit modifications so they get uploaded to the graphics card
	var modified_region = Rect2(Vector2(), heightmap.get_size())
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_NORMAL)
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_SPLAT)

	# Create texture set
	# NOTE: usually this is not made from script, it can be built with editor tools
	var texture_set = HTerrainTextureSet.new()
	texture_set.set_mode(HTerrainTextureSet.MODE_TEXTURES)
	texture_set.insert_slot(-1)
	texture_set.set_texture(0, HTerrainTextureSet.TYPE_ALBEDO_BUMP, grass_texture)
	texture_set.insert_slot(-1)
	texture_set.set_texture(1, HTerrainTextureSet.TYPE_ALBEDO_BUMP, sand_texture)
	texture_set.insert_slot(-1)
	texture_set.set_texture(2, HTerrainTextureSet.TYPE_ALBEDO_BUMP, rock_texture)
	texture_set.insert_slot(-1)
	texture_set.set_texture(3, HTerrainTextureSet.TYPE_ALBEDO_BUMP, flower_texture)

	# Create terrain node
	var terrain = HTerrain.new()
	terrain.set_shader_type(HTerrain.SHADER_CLASSIC4_LITE)
	terrain.set_data(terrain_data)
	terrain.set_texture_set(texture_set)
	add_child(terrain)

func get_island_factor(x : float, z : float, center : Vector2) -> float :
	var distance := Vector2(x, z).distance_to(center)
	var curve_position := distance / island_size
	
	return height_curve.interpolate(1.0 - curve_position)
	# No need to call this, but you may need to if you edit the terrain later on
	#terrain.update_collider()

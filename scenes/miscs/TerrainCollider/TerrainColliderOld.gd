tool
extends Spatial



const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")
const HTerrainCollider = preload("res://addons/zylann.hterrain/hterrain_collider.gd")
const Logger = preload("res://addons/zylann.hterrain/util/logger.gd")

const MIN_MAP_SCALE = 0.01

export var map_scale := Vector3(1, 1, 1) setget set_map_scale


var _logger = Logger.get_for(self)

var _data : HTerrainData

var _collision_enabled := false
var _collider: HTerrainCollider = null
var _collision_layer := 1
var _collision_mask := 1


# Called when the node enters the scene tree for the first time.
func _ready():
	
	print("Ready %s" % self.name)
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _check_heightmap_collider_support() -> bool:
	var v = Engine.get_version_info()
	if v.major == 3 and v.minor == 0 and v.patch < 4:
		_logger.error("Heightmap collision shape not supported in this version of Godot,"
			+ " please upgrade to 3.0.4 or later")
		return false
	return true


func _set_data_directory(dirpath : String):
	if dirpath != _get_data_directory():
		if dirpath == "":
			set_data(null)
		else:
			var fpath := dirpath.plus_file(HTerrainData.META_FILENAME)
			var f := File.new()
			if f.file_exists(fpath):
				# Load existing
				var d = load(fpath)
				set_data(d)
			else:
				# Create new
				var d := HTerrainData.new()
				d.resource_path = fpath
				set_data(d)
	else:
		_logger.warn("Setting twice the same terrain directory??")


func _get_data_directory() -> String:
	if _data != null:
		return _data.resource_path.get_base_dir()
	return ""


func _get_property_list():
	# A lot of properties had to be exported like this instead of using `export`,
	# because Godot 3 does not support easy categorization and lacks some hints
	var props = [
		{
			# Terrain data is exposed only as a path in the editor,
			# because it can only be saved if it has a directory selected.
			# That property is not used in scene saving (data is instead).
			"name": "data_directory",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_EDITOR,
			"hint": PROPERTY_HINT_DIR
		},
		{
			# The actual data resource is only exposed for storage.
			# I had to name it so that Godot won't try to assign _data directly
			# instead of using the setter I made...
			"name": "_terrain_data",
			"type": TYPE_OBJECT,
			"usage": PROPERTY_USAGE_STORAGE,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			# This actually triggers `ERROR: Cannot get class`,
			# if it were to be shown in the inspector.
			# See https://github.com/godotengine/godot/pull/41264
			"hint_string": "HTerrainData"
		},
		{
			"name": "Collision",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_GROUP
		},
		{
			"name": "collision_enabled",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
		},
		{
			"name": "collision_layer",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
			"hint": PROPERTY_HINT_LAYERS_3D_PHYSICS
		},
		{
			"name": "collision_mask",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE,
			"hint": PROPERTY_HINT_LAYERS_3D_PHYSICS
		}
	]
	return props


func _get(key: String):
	if key == "data_directory":
		return _get_data_directory()

	if key == "_terrain_data":
		if _data == null or _data.resource_path == "":
			# Consider null if the data is not set or has no path,
			# because in those cases we can't save the terrain properly
			return null
		else:
			return _data
	elif key == "collision_enabled":
		return _collision_enabled
	elif key == "collision_layer":
		return _collision_layer
	elif key == "collision_mask":
		return _collision_mask
	

func _set(key: String, value):
	if key == "data_directory":
		_set_data_directory(value)

	# Can't use setget when the exported type is custom,
	# because we were also are forced to use _get_property_list...
	elif key == "_terrain_data":
		set_data(value)

		
	elif key == "collision_enabled":
		set_collision_enabled(value)

	elif key == "collision_layer":
		_collision_layer = value
		if _collider != null:
			_collider.set_collision_layer(value)

	elif key == "collision_mask":
		_collision_mask = value
		if _collider != null:
			_collider.set_collision_mask(value)


func set_map_scale(p_map_scale: Vector3):
	if map_scale == p_map_scale:
		return
	p_map_scale.x = max(p_map_scale.x, MIN_MAP_SCALE)
	p_map_scale.y = max(p_map_scale.y, MIN_MAP_SCALE)
	p_map_scale.z = max(p_map_scale.z, MIN_MAP_SCALE)
	map_scale = p_map_scale
	_on_transform_changed()


func _notification(what: int):
	
	
	match what:
		NOTIFICATION_ENTER_WORLD:
			if _collider != null:
				_collider.set_world(get_world())
				_collider.set_transform(get_internal_transform())
		
		NOTIFICATION_EXIT_WORLD:
			if _collider != null:
				_collider.set_world(null)
		
		NOTIFICATION_TRANSFORM_CHANGED:
			_on_transform_changed()
	
	pass


func get_internal_transform() -> Transform:
	# Terrain can only be self-scaled and translated,
	return Transform(Basis().scaled(map_scale), global_transform.origin)


func has_data() -> bool:
	return _data != null


func set_data(new_data: HTerrainData):
	assert(new_data == null or new_data is HTerrainData)
	
	print(str("Set new data ", new_data))
	_logger.debug(str("Set new data ", new_data))

	if _data == new_data:
		return

	if has_data():
		"""
		_logger.debug("Disconnecting old HeightMapData")
		_data.disconnect("resolution_changed", self, "_on_data_resolution_changed")
		_data.disconnect("region_changed", self, "_on_data_region_changed")
		_data.disconnect("map_changed", self, "_on_data_map_changed")
		_data.disconnect("map_added", self, "_on_data_map_added")
		_data.disconnect("map_removed", self, "_on_data_map_removed")
		
		
		if _normals_baker != null:
			_normals_baker.set_terrain_data(null)
			_normals_baker.queue_free()
			_normals_baker = null
		"""

	_data = new_data

	# Note: the order of these two is important
	#_clear_all_chunks()

	if has_data():
		
		
		print("Connecting new HeightMapData")
		_logger.debug("Connecting new HeightMapData")
		
		
		if _collider != null:
			print("_collider.create_from_terrain_data")
			_collider.create_from_terrain_data(_data)
		
		"""
		_data.connect("resolution_changed", self, "_on_data_resolution_changed")
		_data.connect("region_changed", self, "_on_data_region_changed")
		_data.connect("map_changed", self, "_on_data_map_changed")
		_data.connect("map_added", self, "_on_data_map_added")
		_data.connect("map_removed", self, "_on_data_map_removed")
		
		
		if _normals_baker != null:
			_normals_baker.set_terrain_data(_data)
		"""
		#_on_data_resolution_changed()

	#_material_params_need_update = true
	
	#Util.update_configuration_warning(self, true)
	
	print("Set data done")
	_logger.debug("Set data done")


func set_collision_enabled(enabled: bool):
	
	if _collision_enabled != enabled:
		_collision_enabled = enabled
		if _collision_enabled:
			if _check_heightmap_collider_support():
				print("Create collider")
				_collider = HTerrainCollider.new(self, _collision_layer, _collision_mask)
				# Collision is not updated with data here,
				# because loading is quite a mess at the moment...
				# 1) This function can be called while no data has been set yet
				# 2) I don't want to update the collider more times than necessary
				#    because it's expensive
				# 3) I would prefer not defer that to the moment the terrain is
				#    added to the tree, because it would screw up threaded loading
		else:
			# Despite this object being a Reference,
			# this should free it, as it should be the only reference
			_collider = null


func update_collider():
	assert(_collision_enabled)
	assert(_collider != null)
	print("_collider.create_from_terrain_data")
	_collider.create_from_terrain_data(_data)


func _on_transform_changed():
	_logger.debug("Transform changed")
	
	if not is_inside_tree():
		# The transform and other properties can be set by the scene loader,
		# before we enter the tree
		return
	
	var gt = get_internal_transform()
	
	#_for_all_chunks(TransformChangedAction.new(gt))
	
	#_material_params_need_update = true
	
	if _collider != null:
		_collider.set_transform(gt)
	
	#emit_signal("transform_changed", gt)

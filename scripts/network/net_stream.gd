class_name NetStream
extends Reference



class NetLimitTransform:
	var limit_x : Vector2
	var limit_y : Vector2
	var limit_z : Vector2
	var res : float
	
	func _init(x: Vector2, y: Vector2, z: Vector2, r : float):
		limit_x = x
		limit_y = y
		limit_z = z
		res = r
	


static func serialize_bool(stream : NetStream, value: bool) -> bool:
	
	return true if stream.serialize_bits(value, 1) > 0 else false
	


static func serialize_int(stream : NetStream, value : int, vmin : int, vmax: int) -> int:
	var delta := vmax - vmin
	var bits := _bits_required(0, delta)
	var raw_value := 0
	if stream.is_writing():
		raw_value = value - vmin
	raw_value = stream.serialize_bits(raw_value, bits)
	if stream.is_reading():
		value = raw_value + vmin
	return value



static func serialize_float(stream : NetStream, value : float, vmin : float, vmax : float, res : float) -> float:
	var delta : float = vmax - vmin
	var max_integer_value : int = int( ceil( delta / res ) )
	var bits : int= _bits_required(0, max_integer_value)
	var raw_value : int = 0
	if stream.is_writing():
		var normalized_value : float = max(0.0, min(1.0, (value - vmin) / delta) )
		raw_value = int( floor( float(normalized_value * max_integer_value) + 0.5) )
	raw_value = stream.serialize_bits(raw_value, bits)
	if stream.is_reading():
		var normalized_value : float = float(raw_value / float(max_integer_value))
		value = normalized_value * delta + vmin
	return value


static func serialize_vector2_dir(stream: NetStream, vector: Vector2, vmax := 100.0, res := 0.01) -> Vector2:
	var normalized := 1 if vmax == 1.0 else 0
	var magnitude = vector.length()
	var v := vector
	if stream.is_writing():
		v = vector.normalized()
	v.x = serialize_float(stream, v.x, -1.0, 1.0, res)
	v.y = serialize_float(stream, v.y, -1.0, 1.0, res)
	normalized = stream.serialize_bits(normalized, 1)
	if not normalized:
		magnitude = serialize_float(stream, magnitude, 0.0, vmax, res)
		if stream.is_reading():
			v = v * magnitude
	return v


static func serialize_vector2(stream: NetStream, vector: Vector2, vmin := 0.0, vmax := 100.0, res := 0.01) -> Vector2:
	vector.x = serialize_float(stream, vector.x, vmin, vmax, res)
	vector.y = serialize_float(stream, vector.y, vmin, vmax, res)
	return vector


static func serialize_vector3_dir(stream: NetStream, vector: Vector3, vmax := 100.0, res := 0.01) -> Vector3:
	var normalized := 1 if vmax == 1.0 else 0
	var magnitude = vector.length()
	var v = vector
	if stream.is_writing():
		v = vector.normalized()
	v.x = serialize_float(stream, v.x, -1.0, 1.0, res)
	v.y = serialize_float(stream, v.y, -1.0, 1.0, res)
	v.z = serialize_float(stream, v.z, -1.0, 1.0, res)
	normalized = stream.serialize_bits(normalized, 1)
	if not normalized:
		magnitude = serialize_float(stream, magnitude, 0.0, vmax, res)
		if stream.is_reading():
			v = v * magnitude
	return v


static func serialize_vector3(stream: NetStream, vector: Vector3, vmin := 0.0, vmax := 100.0, res := 0.01) -> Vector3:
	vector.x = serialize_float(stream, vector.x, vmin, vmax, res)
	vector.y = serialize_float(stream, vector.y, vmin, vmax, res)
	vector.z = serialize_float(stream, vector.z, vmin, vmax, res)
	return vector


static func serialize_quat(stream: NetStream, quat : Quat) -> Quat:
	"""
	quat.x = serialize_float(stream, quat.x, -1.0, 1.0, 0.001)
	quat.y = serialize_float(stream, quat.y, -1.0, 1.0, 0.001)
	quat.z = serialize_float(stream, quat.z, -1.0, 1.0, 0.001)
	quat.w = serialize_float(stream, quat.w, -1.0, 1.0, 0.001)
	return quat
	"""
	var abs_x := abs(quat.x)
	var abs_y := abs(quat.y)
	var abs_z := abs(quat.z)
	var abs_w := abs(quat.w)
	
	# select wich value will be droped
	var drop_x := true if abs_x > abs_y and abs_x > abs_z and abs_x > abs_w else false
	var drop_y := true if abs_y > abs_x and abs_y > abs_z and abs_y > abs_w else false
	var drop_z := true if abs_z > abs_x and abs_z > abs_y and abs_z > abs_w else false
	var drop_w := true if abs_w > abs_x and abs_w > abs_y and abs_w > abs_z else false
	
	drop_x = stream.serialize_bool(stream, drop_x)
	drop_y = stream.serialize_bool(stream, drop_y)
	drop_z = stream.serialize_bool(stream, drop_z)
	drop_w = stream.serialize_bool(stream, drop_w)
	
	# TODO : avoid send negative bit
	var negative := true if( (drop_x and quat.x < 0.0) or (drop_y and quat.y < 0.0) or (drop_z and quat.z < 0.0) or (drop_w and quat.w < 0.0) ) else false
	
	negative = stream.serialize_bool(stream, negative)
	
	if not drop_x:
		quat.x = serialize_float(stream, quat.x, -1.0, 1.0, 0.001)
	if not drop_y:
		quat.y = serialize_float(stream, quat.y, -1.0, 1.0, 0.001)
	if not drop_z:
		quat.z = serialize_float(stream, quat.z, -1.0, 1.0, 0.001)
	if not drop_w:
		quat.w = serialize_float(stream, quat.w, -1.0, 1.0, 0.001)
	
	if drop_x:
		quat.x = sqrt(1.0 - quat.y*quat.y - quat.z*quat.z - quat.w*quat.w)
		if negative:
			quat.x = -quat.x
	
	if drop_y:
		quat.y = sqrt(1.0 - quat.x*quat.x - quat.z*quat.z - quat.w*quat.w)
		if negative:
			quat.y = -quat.y
	
	if drop_z:
		quat.z = sqrt(1.0 - quat.x*quat.x - quat.y*quat.y - quat.w*quat.w)
		if negative:
			quat.z = -quat.z
	
	if drop_w:
		quat.w = sqrt(1.0 - quat.x*quat.x - quat.y*quat.y - quat.z*quat.z)
		if negative:
			quat.w = -quat.w
	
	return quat.normalized()


static func serialize_transform(stream : NetStream, transform : Transform, limit_transform : NetLimitTransform) -> Transform:
	transform.basis = Basis( serialize_quat(stream, transform.basis.get_rotation_quat() ) )
	
	transform.origin.x = serialize_float(stream, transform.origin.x, limit_transform.limit_x.x, limit_transform.limit_x.y, limit_transform.res)
	transform.origin.y = serialize_float(stream, transform.origin.y, limit_transform.limit_y.x, limit_transform.limit_y.y, limit_transform.res)
	transform.origin.z = serialize_float(stream, transform.origin.z, limit_transform.limit_z.x, limit_transform.limit_z.y, limit_transform.res)
	
	return transform


static func serialize_string(stream : NetStream, string :="") -> String:
	var raw
	var size = 0
	if stream.is_writing():
		raw = string.to_utf8()
		size = raw.size()
	size = stream.serialize_bits(size, 8)
	
	if stream.is_reading():
		raw = PoolByteArray()
		raw.resize(size)
	
	for index in range(size):
		raw[index] = stream.serialize_bits(raw[index], 8)
	return raw.get_string_from_utf8()


static func _bits_required(from, to) -> int:
	var val = to - from
	
	for i in range(32):
		var index = 31 - i
		var mask = 0x01 << index
		if val & mask:
			return index + 1
	return 1

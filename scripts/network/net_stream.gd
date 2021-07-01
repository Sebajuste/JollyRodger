class_name NetStream
extends Object


static func serialize_bool(stream : NetStream, value: bool) -> bool:
	
	return stream.serialize_bits(value, 1)
	


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
	var magnitude = vector.length()
	var v := vector
	if stream.is_writing():
		v = vector.normalized()
	v.x = serialize_float(stream, v.x, -1.0, 1.0, res)
	v.y = serialize_float(stream, v.y, -1.0, 1.0, res)
	magnitude = serialize_float(stream, magnitude, 0.0, vmax, res)
	if stream.is_reading():
		v = v * magnitude
	return v


static func serialize_vector2(stream: NetStream, vector: Vector2, vmin := 0.0, vmax := 100.0, res := 0.01) -> Vector2:
	vector.x = serialize_float(stream, vector.x, vmin, vmax, res)
	vector.y = serialize_float(stream, vector.y, vmin, vmax, res)
	return vector


static func serialize_vector3_dir(stream: NetStream, vector: Vector3, vmax := 100.0, res := 0.01) -> Vector3:
	var magnitude = vector.length()
	var v = vector
	if stream.is_writing():
		v = vector.normalized()
	v.x = serialize_float(stream, v.x, -1.0, 1.0, res)
	v.y = serialize_float(stream, v.y, -1.0, 1.0, res)
	v.z = serialize_float(stream, v.z, -1.0, 1.0, res)
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
	quat.x = serialize_float(stream, quat.x, -1.0, 1.0, 0.001)
	quat.y = serialize_float(stream, quat.y, -1.0, 1.0, 0.001)
	quat.z = serialize_float(stream, quat.z, -1.0, 1.0, 0.001)
	quat.w = serialize_float(stream, quat.w, -1.0, 1.0, 0.001)
	return quat


static func serialize_transform(stream : NetStream, transform : Transform, pmin := -1000.0, pmax := 1000.0, res := 0.001) -> Transform:
	transform.basis = Basis( serialize_quat(stream, Quat( transform.basis ) ) )
	transform.origin = serialize_vector3(stream, transform.origin, pmin, pmax, res)
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

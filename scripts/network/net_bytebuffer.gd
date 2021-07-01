extends Object

class_name NetByteBuffer


var _raw_array : PoolByteArray
var _position := 0
var _limit : int


func _init(capacity: int):
	_raw_array = PoolByteArray()
	_raw_array.resize(capacity)
	_position = 0
	_limit = capacity


func clear():
	_position = 0
	_limit = _raw_array.size()


func flip():
	_limit = _position
	_position = 0


func position() -> int:
	return _position


func limit() -> int:
	return _limit


func array() -> PoolByteArray:
	return _raw_array


func get_byte() -> int:
	if _position < _limit:
		var value = _raw_array[_position]
		_position = _position + 1
		return value
	return -1


func put_byte(value: int):
	if _position < _limit:
		_raw_array[_position] = value & 0xFF
		_position = _position + 1


func get_int() -> int:
	if _position + 4 <= _limit:
		var raw = 0
		raw = raw | _raw_array[_position]
		raw = raw | ( _raw_array[_position+1] << 8 )
		raw = raw | ( _raw_array[_position+2] << 16 )
		raw = raw | ( _raw_array[_position+3] << 24 )
		_position = _position + 4
		return raw
	return -1


func put_int(value: int):
	if _position + 4 <= _limit:
		_raw_array[_position+3] = (value & 0xFF000000 ) >> 24
		_raw_array[_position+2] = (value & 0x00FF0000 ) >> 16
		_raw_array[_position+1] = (value & 0x0000FF00 ) >> 8
		_raw_array[_position] = value & 0x000000FF
		_position = _position + 4

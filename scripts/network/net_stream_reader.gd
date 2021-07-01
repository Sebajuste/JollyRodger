extends NetStream

class_name NetStreamReader


var _bit_packer : NetBitPackerReader


func _init(byte_buffer : NetByteBuffer):
	_bit_packer = NetBitPackerReader.new(byte_buffer)


func is_writing() -> bool:
	return false


func is_reading() -> bool:
	return true


func serialize_bits(_value : int, bits : int) -> int:
	return _bit_packer.read(bits)


func serialize_vector(vector: Vector3):
	vector.x = _bit_packer.read(32)
	vector.y = _bit_packer.read(32)
	vector.z = _bit_packer.read(32)


func flush():
	_bit_packer.flush()

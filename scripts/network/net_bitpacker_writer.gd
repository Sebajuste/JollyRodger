extends NetBitPacker

class_name NetBitPackerWriter


var _scratch : int
var _scratch_bits : int
var _num_bits_write : int
var _byte_buffer : NetByteBuffer


func _init(byte_buffer: NetByteBuffer):
	_scratch = 0
	_scratch_bits = 0
	_num_bits_write = 0
	_byte_buffer = byte_buffer


func write(val: int, bits: int) -> bool:
	if bits <= 0:
		return false
	if bits + _scratch_bits > 32:
		var bits_remained = 32 - _scratch_bits
		_scratch = _scratch | ( (val & _mask(bits_remained) ) << _scratch_bits )
		_scratch_bits = _scratch_bits + bits_remained
		_num_bits_write = _num_bits_write + bits_remained
		val = val >> bits_remained
		bits = bits - bits_remained
		flush()
	_scratch = _scratch | ( (val & _mask(bits) ) << _scratch_bits )
	_scratch_bits = _scratch_bits + bits
	_num_bits_write = _num_bits_write + bits
	if _scratch_bits > 32:
		flush()
	return true


func num_bits_write() -> int:
	return _num_bits_write


func flush():
	_byte_buffer.put_int(_scratch & 0xFFFFFFFF)
	_scratch = 0
	if _scratch_bits > 32:
		_scratch_bits = _scratch_bits - 32
	else:
		_scratch_bits = 0

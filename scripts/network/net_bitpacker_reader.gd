extends NetBitPacker

class_name NetBitPackerReader


var _scratch : int = 0
var _scratch_bits : int = 0
var _num_bits_read : int = 0
var _total_bits : int
var _byte_buffer : NetByteBuffer


func _init(byte_buffer : NetByteBuffer):
	_scratch = 0
	_scratch_bits = 0
	_num_bits_read = 0
	_total_bits = byte_buffer.limit() * 8
	_byte_buffer = byte_buffer


func read(bits: int) -> int:
	var raw := 0
	var bits_remained := 32
	var value := 0
	
	if _scratch_bits == 0 || bits > _scratch_bits:
		
		raw = _byte_buffer.get_int()
		bits_remained = 32 - _scratch_bits
		_scratch = (_scratch & _mask(_scratch_bits) ) | ( ( raw & _mask(bits_remained) ) << _scratch_bits )
		_scratch_bits = 32
		if bits_remained == 32:
			raw = 0
		else:
			raw = (raw >> bits_remained) & _mask(32 - bits_remained)
	
	if bits == 32:
		value = _scratch
	else:
		value = _scratch & _mask(bits)
	if bits == 32:
		_scratch = 0
	else:
		_scratch = ( (_scratch  ) >> bits) & _mask(32 - bits)
	_scratch_bits = _scratch_bits - bits
	_scratch = ( _scratch | (raw << _scratch_bits ) )
	_scratch_bits = _scratch_bits + ( 32 - bits_remained )
	_num_bits_read = _num_bits_read + bits
	
	return value


func flush():
	_scratch_bits = 0
	_scratch = 0

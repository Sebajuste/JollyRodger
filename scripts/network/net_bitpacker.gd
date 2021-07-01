extends Object

class_name NetBitPacker


static func _mask(bits: int) -> int:
	if bits >= 32:
		return 0xFFFFFFFF
	return (1 << bits) - 1;


func flush():
	pass


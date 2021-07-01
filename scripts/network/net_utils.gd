extends Object

class_name NetUtils


static func byte_buffer_from_byte_array(raw_array: PoolByteArray) -> NetByteBuffer:
	var buffer = NetByteBuffer.new(raw_array.size())
	buffer._raw_array = raw_array
	return buffer


static func byte_buffer_to_str(byte_buffer: NetByteBuffer) -> String:
	var buffer_str := ""
	for i in range(0, byte_buffer.limit() ):
		buffer_str += str( "%02X" % byte_buffer._raw_array[i] ) + " "
	return buffer_str

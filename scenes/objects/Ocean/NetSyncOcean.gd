extends NetNodeSync


onready var ocean : Ocean = owner




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	
#	pass


func sync_ocean():
	
	if not Network.is_enabled() or not is_network_master():
		return
	
	var properties := {
		"wave_direction": ocean.wave_direction,
		"amplitude": ocean.amplitude,
		"steepness": ocean.steepness,
		"ocean_time": ocean.ocean_time * 1000
	}
	
	var byte_buffer := NetByteBuffer.new(64)
	var write_stream := NetStreamWriter.new(byte_buffer)
	
	var _r = null
	
	packet_id = packet_id + 1
	_r = write_stream.serialize_bits(packet_id, 32) # frequency
	_r = write_stream.serialize_bits($Timer.wait_time * 1000, 8) # frequency
	
	_serialize(write_stream, properties)
	
	write_stream.flush()
	byte_buffer.flip()
	
	var byte_packet : PoolByteArray = byte_buffer.array()
	byte_packet.resize( byte_buffer.limit() )
	
	for peer_id in peers:
		rpc_unreliable_id(peer_id, "rpc_sync_ocean", byte_packet)
	


puppet func rpc_sync_ocean(byte_packet : PoolByteArray):
	
	var last_packet_time := packet_time
	packet_time = current_time
	
	var read_buffer := NetUtils.byte_buffer_from_byte_array(byte_packet)
	var read_stream := NetStreamReader.new(read_buffer)
	
	packet_id = read_stream.serialize_bits(packet_id, 32) # frequency
	var packet_frequency : float = read_stream.serialize_bits(0, 8) / 1000.0 # frequency
	
	packet_delta = packet_id - last_packet_id_received
	if packet_delta == 0:
		packet_delta = 1
	
	var except_packet_time = last_packet_time + packet_delta * packet_frequency
	
	var jitter_time = current_time - except_packet_time
	
	
	var properties := {
		"wave_direction": Vector2(),
		"amplitude": 0.0,
		"steepness": 0.0,
		"ocean_time": 0
	}
	
	_serialize(read_stream, properties)
	
	last_packet_id_received = packet_id
	
	# Jitter correction
	if jitter_time > 0:
		properties.ocean_time = properties.ocean_time + jitter_time * 1000 # project out received position
		pass
	
	ocean.wave_direction = properties.wave_direction
	
	if ocean.amplitude != properties.amplitude:
		ocean.set_amplitude(properties.amplitude)
	
	if ocean.steepness != properties.steepness:
		ocean.set_steepness(properties.steepness)
	
	ocean.ocean_time = NetNodeSync.update_float(ocean.ocean_time, float(properties.ocean_time) / 1000.0, 0.1)
	


func _serialize(stream : NetStream, properties: Dictionary ):
	
	properties.wave_direction = NetStream.serialize_vector2_dir(stream, properties.wave_direction, 1.0, 0.01)
	properties.amplitude = NetStream.serialize_float(stream, properties.amplitude, 0.0, 100.0, 0.1)
	properties.steepness = NetStream.serialize_float(stream, properties.steepness, 0.0, 1.0, 0.001)
	properties.ocean_time = stream.serialize_bits(properties.ocean_time, 32)
	

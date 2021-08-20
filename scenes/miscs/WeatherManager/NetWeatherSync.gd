extends NetNodeSync


onready var weather_manager = owner


# Called when the node enters the scene tree for the first time.
func _ready():
	if Network.enabled and is_network_master():
		$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_state() -> Dictionary:
	return {
		"weather_offset": owner.weather_offset
	}


func set_state(state : Dictionary):
	if state.has("weather_offset"):
		owner.weather_offset = state.weather_offset


func sync_weather():
	
	if not Network.is_enabled() or not is_network_master():
		return
	
	var properties := {
		"weather_offset": weather_manager.weather_offset * 1000,
		"weather_change_speed": weather_manager.weather_change_speed,
		"weather_interpolation_speed": weather_manager.weather_interpolation_speed
	}
	
	var byte_buffer := NetByteBuffer.new(64)
	var write_stream := NetStreamWriter.new(byte_buffer)
	
	var _r
	
	packet_id = packet_id + 1
	_r = write_stream.serialize_bits(packet_id, 32) # frequency
	_r = write_stream.serialize_bits($Timer.wait_time * 1000, 8) # frequency
	
	_serialize(write_stream, properties)
	
	write_stream.flush()
	byte_buffer.flip()
	
	var byte_packet : PoolByteArray = byte_buffer.array()
	byte_packet.resize( byte_buffer.limit() )
	
	for peer_id in peers:
		rpc_unreliable_id(peer_id, "rpc_sync_weather", byte_packet)
	pass


puppet func rpc_sync_weather(byte_packet : PoolByteArray):
	
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
		"weather_offset": 0.0,
		"weather_change_speed": 0.0,
		"weather_interpolation_speed": 0.0
	}
	
	_serialize(read_stream, properties)
	
	last_packet_id_received = packet_id
	
	# Jitter correction
	if jitter_time > 0:
		#properties.ocean_time = properties.ocean_time + jitter_time * 1000 # project out received position
		pass
	
	weather_manager.weather_offset = NetNodeSync.update_float(weather_manager.weather_offset, float(properties.weather_offset) / 1000.0, 0.1)
	
	weather_manager.weather_change_speed = properties.weather_change_speed
	weather_manager.weather_interpolation_speed = properties.weather_interpolation_speed


func _serialize(stream : NetStream, properties: Dictionary ):
	
	properties.weather_offset = stream.serialize_bits(properties.weather_offset, 32)
	properties.weather_change_speed = NetStream.serialize_float(stream, properties.weather_change_speed, 0.0, 100.0, 0.1)
	properties.weather_interpolation_speed = NetStream.serialize_float(stream, properties.weather_interpolation_speed, 0.0, 10.0, 0.1)
	

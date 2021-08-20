extends NetNodeSync


onready var time_manager = owner


# Called when the node enters the scene tree for the first time.
func _ready():
	
	if Network.enabled and is_network_master():
		$Timer.start()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_state() -> Dictionary:
	return {
		"hours": owner.hours,
		"minutes": owner.minutes,
		"seconds": owner.seconds
	}


func set_state(state : Dictionary):
	if state.has("hours"):
		owner.hours = state.hours
	if state.has("minutes"):
		owner.minutes = state.minutes
	if state.has("seconds"):
		owner.seconds = state.seconds


func sync_time():
	
	if not Network.is_enabled() or not is_network_master():
		return
	
	var properties := {
		"hours": time_manager.hours,
		"minutes": time_manager.minutes,
		"seconds": time_manager.seconds
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
		rpc_unreliable_id(peer_id, "rpc_sync_time", byte_packet)


puppet func rpc_sync_time(byte_packet : PoolByteArray):
	
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
		"hours": 0,
		"minutes": 0,
		"seconds": 0
	}
	
	_serialize(read_stream, properties)
	
	last_packet_id_received = packet_id
	
	# Jitter correction
	if jitter_time > 0:
		#properties.ocean_time = properties.ocean_time + jitter_time * 1000 # project out received position
		pass
	
	time_manager.hours = properties.hours
	time_manager.minutes = properties.minutes
	time_manager.seconds = properties.seconds
	


func _serialize(stream : NetStream, properties: Dictionary ):
	
	properties.hours = NetStream.serialize_int(stream, properties.hours, 0, 24)
	properties.minutes = NetStream.serialize_int(stream, properties.minutes, 0, 60)
	properties.seconds = NetStream.serialize_int(stream, properties.seconds, 0, 60)
	
	pass
	

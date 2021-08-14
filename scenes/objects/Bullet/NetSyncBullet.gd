extends NetNodeSync


onready var bullet : RigidBody = owner


var last_properties_received := {}
var slave_updated := true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func integrate_forces(state : PhysicsDirectBodyState):
	
	if Network.enabled and not is_network_master() and not slave_updated:
		state.linear_velocity = last_properties_received.linear_velocity
		state.transform.origin = NetNodeSync.update_vector3(state.transform.origin, last_properties_received.position, 0.2)
		slave_updated = true
	


master func sync_node_emission():
	
	if not Network.is_enabled() or not is_network_master():
		return
	
	var properties := {
		"linear_velocity": bullet.linear_velocity,
		"position": bullet.global_transform.origin
	}
	
	var byte_buffer := NetByteBuffer.new(64)
	var write_stream := NetStreamWriter.new(byte_buffer)
	
	var _r
	packet_id = packet_id + 1
	_r = write_stream.serialize_bits(packet_id, 32) # frequency
	_r = write_stream.serialize_bits($Timer.wait_time * 1000, 8) # frequency
	
	_r = _serialize(write_stream, properties)
	
	write_stream.flush()
	byte_buffer.flip()
	
	var byte_packet : PoolByteArray = byte_buffer.array()
	byte_packet.resize( byte_buffer.limit() )
	
	#print("send byte_packet [%d]: " % byte_buffer.limit(), NetUtils.byte_buffer_to_str(byte_buffer) )
	
	rpc_unreliable("sync_node_reception", byte_packet)
	


puppet func sync_node_reception(byte_packet : PoolByteArray):
	
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
		"linear_velocity": Vector3(),
		"position": Vector3(),
	}
	
	_serialize(read_stream, properties)
	
	last_packet_id_received = packet_id
	
	# Jitter correction
	if jitter_time > 0:
		properties.position = properties.position + properties.linear_velocity * jitter_time    # project out received position
	
	last_properties_received = properties
	
	slave_updated = false


func _serialize(stream : NetStream, properties: Dictionary):
	
	properties.linear_velocity = NetStream.serialize_vector3_dir(stream, properties.linear_velocity, 100.0, 0.01)
	properties.position.x = NetStream.serialize_float(stream, properties.position.x, -10000, 10000, 0.01)
	properties.position.y = NetStream.serialize_float(stream, properties.position.y, -50, 500, 0.01)
	properties.position.z = NetStream.serialize_float(stream, properties.position.z, -10000, 10000, 0.01)
	#properties.angular_velocity = NetStream.serialize_vector3_dir(stream, properties.angular_velocity, 20.0, 0.01)
	#properties.transform = NetStream.serialize_transform(stream, properties.transform, -10000, 10000, 0.001)
	
	pass

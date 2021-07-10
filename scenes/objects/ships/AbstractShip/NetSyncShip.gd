extends NetNodeSync


var LIMIT_TRANSFORM := NetStream.NetLimitTransform.new(
	Vector2(-10000, 10000),
	Vector2(-200, 50),
	Vector2(-10000, 10000),
	0.01
)


onready var ship : AbstractShip = owner


var last_properties := {}

var slave_updated := true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func integrate_forces(state : PhysicsDirectBodyState):
	
	
	if Network.enabled and not is_network_master() and not slave_updated:
		
		state.linear_velocity = last_properties.linear_velocity
		state.angular_velocity = last_properties.angular_velocity
		
		state.transform = NetNodeSync.update_transform(state.transform, last_properties.transform)
		
		slave_updated = true
	
	pass


master func sync_ship():
	
	if not Network.is_enabled() or not is_network_master():
		return
	
	var properties := {
		"linear_velocity": ship.linear_velocity,
		"angular_velocity": ship.angular_velocity,
		"transform": ship.global_transform,
		"rudder_position": ship.rudder_position,
		"sail_position": ship.sail_position
	}
	
	var byte_buffer := NetByteBuffer.new(64)
	var write_stream := NetStreamWriter.new(byte_buffer)
	
	packet_id = packet_id + 1
	write_stream.serialize_bits(packet_id, 32) # frequency
	write_stream.serialize_bits($Timer.wait_time * 1000, 8) # frequency
	
	_serialize(write_stream, properties)
	
	write_stream.flush()
	byte_buffer.flip()
	
	var byte_packet : PoolByteArray = byte_buffer.array()
	byte_packet.resize( byte_buffer.limit() )
	
	# print("send byte_packet [%d]: " % byte_buffer.limit(), NetUtils.byte_buffer_to_str(byte_buffer) )
	
	rpc_unreliable("sync_ship_reception", byte_packet)
	
	pass


puppet func sync_ship_reception(byte_packet : PoolByteArray):
	
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
		"angular_velocity": Vector3(),
		"transform": Transform(),
		"rudder_position": 0.0,
		"sail_position": 0.0
	}
	
	_serialize(read_stream, properties)
	
	last_packet_id_received = packet_id
	
	# Jitter correction
	if jitter_time > 0:
		properties.transform.origin = properties.transform.origin + properties.linear_velocity * jitter_time    # project out received position
	
	
	ship.rudder_position = properties.rudder_position
	ship.sail_position = properties.sail_position
	
	last_properties = properties
	
	slave_updated = false
	


func _serialize(stream : NetStream, properties: Dictionary ):
	
	properties.linear_velocity = NetStream.serialize_vector3_dir(stream, properties.linear_velocity, 15.0, 0.01)
	properties.angular_velocity = NetStream.serialize_vector3_dir(stream, properties.angular_velocity, 20.0, 0.01)
	properties.transform = NetStream.serialize_transform(stream, properties.transform, LIMIT_TRANSFORM)
	
	properties.rudder_position = NetStream.serialize_float(stream, properties.rudder_position, -1.0, 1.0, 0.01)
	properties.sail_position = NetStream.serialize_float(stream, properties.sail_position, 0.0, 1.0, 0.01)
	

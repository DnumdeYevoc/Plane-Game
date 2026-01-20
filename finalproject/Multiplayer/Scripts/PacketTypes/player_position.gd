class_name PlayerPosition extends PacketInfo

var id: int
var position: Vector3
var rotation_z : float

static func create(id_: int, position_: Vector3, rotation_z_: float) -> PlayerPosition:
	var info : PlayerPosition = PlayerPosition.new()
	info.packet_type = PACKET_TYPE.PLAYER_POSITION
	info.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	info.id = id_
	info.position = position_
	info.rotation_z = rotation_z_
	return info
	
static func create_from_data(data: PackedByteArray) -> PlayerPosition:
	var info: PlayerPosition = PlayerPosition.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data: PackedByteArray  = super.encode()
	data.resize(18)
	data.encode_u8(1,id)
	#floats take 4 btyes of data
	data.encode_float(2, position.x)
	data.encode_float(6, position.y)
	data.encode_float(10, position.z)
	#encode rotation z to sync it
	data.encode_float(14, rotation_z)
	return data
	
func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	position = Vector3(data.decode_float(2), data.decode_float(6), data.decode_float(10))
	rotation_z = data.decode_float(14)

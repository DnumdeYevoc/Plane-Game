class_name Respawn extends PacketInfo

var id: int
var plane_type: int

static func create(id_: int, plane_type_: int) -> Respawn:
	var info : Respawn = Respawn.new()
	info.packet_type = PACKET_TYPE.RESPAWN
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = id_
	info.plane_type = plane_type_

	return info
	
static func create_from_data(data: PackedByteArray) -> Respawn:
	var info: Respawn = Respawn.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	data.resize(3)
	data.encode_u8(1, id)
	data.encode_u8(2, plane_type)
	return data 

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	plane_type = data.decode_u8(2)

	

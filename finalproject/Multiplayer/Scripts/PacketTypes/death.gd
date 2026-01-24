class_name Death extends PacketInfo

var id: int
var killer: int

static func create(id_: int, killer_: int) -> Death:
	var info : Death = Death.new()
	info.packet_type = PACKET_TYPE.DEATH
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = id_
	info.killer = killer_

	return info
	
static func create_from_data(data: PackedByteArray) -> Death:
	var info: Death = Death.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	data.resize(3)
	data.encode_u8(1, id)
	data.encode_u8(2, killer)
	return data 

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	killer = data.decode_u8(2)

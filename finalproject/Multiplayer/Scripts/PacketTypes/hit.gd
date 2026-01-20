class_name Hit extends PacketInfo

var id: int
var remaining_health : int

static func create(id_: int, remaining_health_ : int) -> Hit:
	var info : Hit = Hit.new()
	info.packet_type = PACKET_TYPE.HIT
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = id_
	info.remaining_health = remaining_health_
	return info
	
static func create_from_data(data: PackedByteArray) -> Hit:
	var info: Hit = Hit.new()
	info.decode(data)
	return info
	
func encode() -> PackedByteArray:
	var data: PackedByteArray  = super.encode()
	data.resize(3)
	data.encode_u8(1,id)
	data.encode_u8(2,remaining_health)
	return data
	
func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	remaining_health = data.decode_u8(2)
	

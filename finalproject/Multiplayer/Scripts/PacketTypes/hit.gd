class_name Hit extends PacketInfo

var id: int
var remaining_health : int

static func create(id: int, remaining_health : int) -> Hit:
	var info : Hit = Hit.new()
	info.packet_type = PACKET_TYPE.HIT
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = id
	info.remaining_health = remaining_health 
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
	

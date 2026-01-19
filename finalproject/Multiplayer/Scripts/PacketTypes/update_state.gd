class_name UpdateState extends PacketInfo

var id: int
var state: int

static func create(id: int, state: int) -> UpdateState:
	var info : UpdateState = UpdateState.new()
	info.packet_type = PACKET_TYPE.UPDATESTATE
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = id
	info.state = state

	return info
	
static func create_from_data(data: PackedByteArray) -> UpdateState:
	var info: UpdateState = UpdateState.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	data.resize(3)
	data.encode_u8(1, id)
	data.encode_u8(2, state)
	return data 

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	state = data.decode_u8(2)

	

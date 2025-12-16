class_name OnServerStart extends PacketInfo

#[PACKET_ID, MAP_RESOURCE_ID, SEED(4-bytes)] IP??
#do you need to include IP in this?
var map_id : int
var seed: int

static func create(map_id : int, seed: int) -> OnServerStart:
	var info : OnServerStart = OnServerStart.new()
	info.packet_type = PACKET_TYPE.ON_SERVER_START
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.map_id = map_id
	info.seed = seed
	return info
	
static func create_from_data(data: PackedByteArray) -> OnServerStart:
	var info: OnServerStart = OnServerStart.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	data.resize(6)
	data.encode_u8(1, map_id)
	data.encode_u32(2, seed)
	return data 

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	map_id = data.decode_u8(1)
	seed = data.decode_u32(2)
	

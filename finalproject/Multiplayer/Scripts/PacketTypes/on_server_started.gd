class_name OnServerStart extends PacketInfo

#[PACKET_ID, MAP_RESOURCE_ID, SEED(4-bytes)] IP??
#do you need to include IP in this?
var map_id : int
var map_seed: int

static func create(map_id_ : int, map_seed_: int) -> OnServerStart:
	var info : OnServerStart = OnServerStart.new()
	info.packet_type = PACKET_TYPE.ON_SERVER_START
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.map_id = map_id_
	info.map_seed = map_seed_
	return info
	
static func create_from_data(data: PackedByteArray) -> OnServerStart:
	var info: OnServerStart = OnServerStart.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	data.resize(6)
	data.encode_u8(1, map_id)
	data.encode_u32(2, map_seed)
	return data 

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	map_id = data.decode_u8(1)
	map_seed = data.decode_u32(2)
	

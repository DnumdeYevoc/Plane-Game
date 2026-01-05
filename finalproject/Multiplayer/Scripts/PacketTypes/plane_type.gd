class_name PlaneType  extends PacketInfo

var id :int
var remoted_plane_ids: Array[int]
#var color: Color #Add this? Customizations

static func create(id:int, remoted_plane_ids: Array[int]) -> PlaneType:
	var info : PlaneType = PlaneType.new()
	info.packet_type = PACKET_TYPE.PLANE_TYPE
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = id

	info.remoted_plane_ids = remoted_plane_ids
	return info
	
static func create_from_data(data: PackedByteArray) -> PlaneType:
	var info: PlaneType = PlaneType.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	data.resize(3+remoted_plane_ids.size())
	data.encode_u8(1, id)
	for i in remoted_plane_ids.size():
		var id: int = remoted_plane_ids[i]
		data.encode_u8(2+i, id)
	return data 

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	for i in range(2, data.size()):
		remoted_plane_ids.append(data.decode_u8(i))

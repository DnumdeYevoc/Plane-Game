class_name PlaneType  extends PacketInfo

var plane_id: int
#var color: Color #Add this? Customizations

static func create(plane_id : int) -> PlaneType:
	var info : PlaneType = PlaneType.new()
	info.packet_type = PACKET_TYPE.PLANE_TYPE
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.plane_id = plane_id
	return info
	
static func create_from_data(data: PackedByteArray) -> PlaneType:
	var info: PlaneType = PlaneType.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	data.resize(2)
	data.encode_u8(1, plane_id)
	return data 

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	plane_id = data.decode_u8(1)

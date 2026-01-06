class_name IDAssignment extends PacketInfo

var id: int
var plane_type: int
var remoted_ids : Array[int]
var remoted_types: Array[int]


static func create(id: int, plane_type: int, remote_ids: Array[int], remote_types: Array[int]) -> IDAssignment:
	var info : IDAssignment = IDAssignment.new()
	info.packet_type = PACKET_TYPE.ID_ASSIGNMENT
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = id
	info.plane_type = plane_type
	info.remoted_ids = remote_ids
	info.remoted_types = remote_types
	return info
	
static func create_from_data(data: PackedByteArray) -> IDAssignment:
	var info: IDAssignment = IDAssignment.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	data.resize(3+remoted_ids.size()+remoted_types.size())
	data.encode_u8(1, id)
	data.encode_u8(2, plane_type)
	for i in remoted_ids.size():
		var id: int = remoted_ids[i]
		data.encode_u8(3+i, id)
	for i in remoted_types.size():
		var type: int = remoted_types[i]
		data.encode_u8(3+remoted_ids.size()+i, type)
	return data 

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	plane_type = data.decode_u8(2)
	for i in range(3, ((data.size()-3)/2) +3):
		remoted_ids.append(data.decode_u8(i))
	for i in range(((data.size()-3)/2) +3, data.size()):
		remoted_types.append(data.decode_u8(i))
	

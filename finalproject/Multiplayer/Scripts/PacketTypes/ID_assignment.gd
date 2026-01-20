class_name IDAssignment extends PacketInfo

var id: int
var plane_type: int
var state: int
var remoted_ids : Array[int]
var remoted_types: Array[int]
var remoted_states: Array[int]

static func create(id_: int, plane_type_: int, state_: int, remote_ids_: Array[int], remote_types_: Array[int], remote_states_: Array[int]) -> IDAssignment:
	var info : IDAssignment = IDAssignment.new()
	info.packet_type = PACKET_TYPE.ID_ASSIGNMENT
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = id_
	info.plane_type = plane_type_
	info.state = state_
	info.remoted_ids = remote_ids_
	info.remoted_types = remote_types_
	info.remoted_states = remote_states_
	return info
	
static func create_from_data(data: PackedByteArray) -> IDAssignment:
	var info: IDAssignment = IDAssignment.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	data.resize(4+remoted_ids.size()+remoted_types.size()+remoted_states.size())
	data.encode_u8(1, id)
	data.encode_u8(2, plane_type)
	data.encode_u8(3, state)
	for i in remoted_ids.size():
		var _id: int = remoted_ids[i]
		data.encode_u8(4+i, _id)
	for i in remoted_types.size():
		var _type: int = remoted_types[i]
		data.encode_u8(4+remoted_ids.size()+i, _type)
	for i in remoted_states.size():
		var _state: int = remoted_states[i]
		data.encode_u8(4+remoted_ids.size()+remoted_types.size()+i, _state)
	return data 

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	plane_type = data.decode_u8(2)
	state = data.decode_u8(3)
	for i in range(4, ((data.size()-4)/3) +4):
		remoted_ids.append(data.decode_u8(i))
	for i in range(((data.size()-4)/3) +4, ((data.size()-4)/3)*2 +4):
		remoted_types.append(data.decode_u8(i))
	for i in range(((data.size()-4)/3)*2 +4, data.size()):
		remoted_states.append(data.decode_u8(i))
	

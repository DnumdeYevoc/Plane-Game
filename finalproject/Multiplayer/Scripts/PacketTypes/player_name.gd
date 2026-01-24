class_name PlayerName extends PacketInfo

var id: int
var player_name: String

static func create(id_: int, player_name_: String) -> PlayerName:
	var info : PlayerName = PlayerName.new()
	info.packet_type = PACKET_TYPE.PLAYER_NAME
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = id_
	info.player_name = player_name_

	return info
	
static func create_from_data(data: PackedByteArray) -> PlayerName:
	var info: PlayerName = PlayerName.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data : PackedByteArray = super.encode()
	var encoded_name =player_name.to_utf8_buffer()
	data.resize(2)
	data.encode_u8(1, id)
	data.append_array(encoded_name)

	return data 

func decode(data: PackedByteArray) -> void:
	print(data)
	super.decode(data)
	var encoded_name : PackedByteArray =[]
	id = data.decode_u8(1)
	for i in range(2, data.size()):
		encoded_name.append(data[i])

	player_name = encoded_name.get_string_from_utf8()

	

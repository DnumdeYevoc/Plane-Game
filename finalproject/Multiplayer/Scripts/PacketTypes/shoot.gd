class_name Shoot extends PacketInfo

var id: int
var target_id: int 
var plane_speed : int # is this needed? or can we pull it from plane type?
var dir : Vector3


static func create(id_: int,target_id_:int, plane_speed_ : int, dir_: Vector3, ) -> Shoot:
	var info : Shoot  = Shoot.new()
	info.packet_type = PACKET_TYPE.SHOOT
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = id_
	info.target_id = target_id_
	info.plane_speed = plane_speed_
	info.dir = dir_
	
	return info
	
static func create_from_data(data: PackedByteArray) -> Shoot:
	var info: Shoot = Shoot.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data: PackedByteArray  = super.encode()
	
	data.resize(16)
	data.encode_u8(1,id)
	data.encode_u8(2,target_id)
	data.encode_u8(3,plane_speed)
	#floats take 4 btyes of data
	data.encode_float(4, dir.x)
	data.encode_float(8, dir.y)
	data.encode_float(12, dir.z)
		
	return data
	
func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	target_id = data.decode_u8(2)
	plane_speed = data.decode_u8(3)
	dir = Vector3(data.decode_float(4), data.decode_float(8), data.decode_float(12))

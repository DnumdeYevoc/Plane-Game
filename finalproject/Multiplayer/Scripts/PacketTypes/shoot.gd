class_name Shoot extends PacketInfo

var id: int
var target_id: int 
var plane_speed : int # is this needed? or can we pull it from plane type?
var dir : Vector3


static func create(id: int,target_id:int, plane_speed : int, dir: Vector3, ) -> Shoot:
	var info : Shoot  = Shoot.new()
	info.packet_type = PACKET_TYPE.SHOOT
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = id
	info.target_id = target_id
	info.plane_speed = plane_speed
	info.dir = dir
	
	return info
	
static func create_from_data(data: PackedByteArray) -> Shoot:
	var info: Shoot = Shoot.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data: PackedByteArray  = super.encode()
	
	if target_id ==-1:
		data.resize(15)
		data.encode_u8(1,id)
		data.encode_u8(2,plane_speed)
		#floats take 4 btyes of data
		data.encode_float(3, dir.x)
		data.encode_float(7, dir.y)
		data.encode_float(11, dir.z)
	else:
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
	if data.size()== 16:
		id = data.decode_u8(1)
		target_id = data.decode_u8(2)
		plane_speed = data.decode_u8(3)
		dir = Vector3(data.decode_float(4), data.decode_float(8), data.decode_float(12))
	else:
		id = data.decode_u8(1)
		
		plane_speed = data.decode_u8(2)
		dir = Vector3(data.decode_float(3), data.decode_float(7), data.decode_float(11))

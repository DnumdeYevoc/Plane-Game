extends Node

signal handle_local_id_assignment(local_id: int)
signal handle_remote_id_assignment(remote_id: int)
signal plane_type_assignment(plane_type: int)
signal handle_player_position(player_position: PlayerPosition)
signal handle_shot(shot : Shoot)

var plane_resource_list : Array = [
	preload("res://Resources/Planes/cardinal_0.tres"),
	preload("res://Resources/Planes/bomber_1.tres"),
]

var plane_ids: Array[int]  #plane types, listed in order of Peer IDs

var id : int = -1
var plane_type : int = -1

var remote_ids: Array[int]

var map_id : int
var seed: int
var world: Node3D

func _ready() -> void:
	NetworkHandler.on_client_packet.connect(on_client_packet)
	world = get_node("/root/Game/World")
	
func on_client_packet(data: PackedByteArray)-> void:
	var packet_type : int = data.decode_u8(0)
	
	match packet_type:
		PacketInfo.PACKET_TYPE.ID_ASSIGNMENT:
			manage_ids(IDAssignment.create_from_data(data))
		PacketInfo.PACKET_TYPE.PLAYER_POSITION:
			handle_player_position.emit(PlayerPosition.create_from_data(data))
		PacketInfo.PACKET_TYPE.ON_SERVER_START:
			print("starting packet recieved")
			set_world(OnServerStart.create_from_data(data))
		PacketInfo.PACKET_TYPE.SHOOT:
			var shot = Shoot.create_from_data(data)
			handle_shot.emit(shot)
		_:
			push_error("Packet type with index", data[0], "unhandled")

func manage_ids(id_assignment:IDAssignment )-> void:
	plane_type = id_assignment.plane_type
	print( id_assignment.remoted_types)
	#handles new IDs and sends signal to spawn them in as other players
	if id == -1:#set id
		id = id_assignment.id
		handle_local_id_assignment.emit(id_assignment.id, plane_type) #you spawned in (client )
		
		remote_ids = id_assignment.remoted_ids
		for remote_id in remote_ids:
			if remote_id == id : continue
			handle_remote_id_assignment.emit(remote_id, id_assignment.remoted_types[remote_id]) #someone else spawned in (you are neighbouring client)
	else:#already set id
		remote_ids.append(id_assignment.id)
		handle_remote_id_assignment.emit(id_assignment.id,  id_assignment.remoted_types[id_assignment.id])
		
func set_world(on_server_start:OnServerStart) -> void:
	world.set_seed_and_id( on_server_start.seed, on_server_start.map_id)

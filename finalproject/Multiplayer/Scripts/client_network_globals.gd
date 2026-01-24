extends Node

signal handle_local_id_assignment(local_id: int)
signal handle_remote_id_assignment(remote_id: int)
signal plane_type_assignment(plane_type: int)
signal handle_player_position(player_position: PlayerPosition)
signal handle_shot(shot : Shoot)
signal handle_hit(hit : Hit)
signal on_death()
signal respawn()
signal client_leaderboard_on_kill(killed :int, killer : int)
signal client_leaderboard_add_player(ids: Array[int])
signal client_leaderboard_set_name(id:int, player_name:String)
var plane_resource_list : Array = [
	preload("res://Resources/Planes/cardinal_0.tres"),
	preload("res://Resources/Planes/raven_1.tres"),
	preload("res://Resources/Planes/pandacopter_2.tres"),
]

var plane_ids: Array[int]  #plane types, listed in order of Peer IDs

var id : int = -1
var plane_type : int = -1
var state : int = -1
var remote_ids: Array[int]

var map_id : int

var world: Node3D

func _ready() -> void:
	NetworkHandler.on_client_packet.connect(on_client_packet)
	client_leaderboard_add_player.emit()

	world = get_node("/root/Game/World")
	
func on_client_packet(data: PackedByteArray)-> void:
	var packet_type : int = data.decode_u8(0)
	
	match packet_type:
		PacketInfo.PACKET_TYPE.ID_ASSIGNMENT:
			manage_ids(IDAssignment.create_from_data(data))
			client_leaderboard_add_player.emit(remote_ids)
		PacketInfo.PACKET_TYPE.PLAYER_NAME:
			var player_name_packet= PlayerName.create_from_data(data)
			client_leaderboard_set_name.emit(player_name_packet.id,player_name_packet.player_name )
		PacketInfo.PACKET_TYPE.PLAYER_POSITION:
			handle_player_position.emit(PlayerPosition.create_from_data(data))
		PacketInfo.PACKET_TYPE.ON_SERVER_START:
			print("starting packet recieved")
			set_world(OnServerStart.create_from_data(data))
		PacketInfo.PACKET_TYPE.SHOOT:
			
			var shot = Shoot.create_from_data(data)
			
			handle_shot.emit(shot)
		PacketInfo.PACKET_TYPE.HIT:
			var hit = Hit.create_from_data(data)
			handle_hit.emit(hit)
		PacketInfo.PACKET_TYPE.RESPAWN:
			var r = Respawn.create_from_data(data)
			if id != r.id:
				respawn.emit(r.id,r.plane_type)
		PacketInfo.PACKET_TYPE.DEATH:
			var death = Death.create_from_data(data)
			client_leaderboard_on_kill.emit(death.id, death.killer)
		_:
			push_error("Packet type with index", data[0], "unhandled")

func manage_ids(id_assignment:IDAssignment )-> void:
	plane_type = id_assignment.plane_type
	state = id_assignment.state
	print( id_assignment.remoted_types, id_assignment.remoted_states)
	#handles new IDs and sends signal to spawn them in as other players
	if id == -1:#set id
		id = id_assignment.id
		handle_local_id_assignment.emit(id_assignment.id, plane_type, state ) #you spawned in (client )
		
		remote_ids = id_assignment.remoted_ids
		for remote_id in remote_ids:
			if remote_id == id : continue
			handle_remote_id_assignment.emit(remote_id, id_assignment.remoted_types[remote_id], id_assignment.remoted_states[remote_id]) #someone else spawned in (you are neighbouring client)
	else:#already set id
		remote_ids.append(id_assignment.id)
		handle_remote_id_assignment.emit(id_assignment.id,  id_assignment.remoted_types[id_assignment.id], id_assignment.remoted_states[id_assignment.id])
		
func set_world(on_server_start:OnServerStart) -> void:
	world.set_seed_and_id( on_server_start.map_seed, on_server_start.map_id)
	

extends Node

signal handle_player_position(peer_id:int, player_position: PlayerPosition)

var peer_ids: Array[int]
var peer_types: Array[int]
var peer_states: Array[int]
var map_id : int
var seed : int

var plane_ids: Array[int]
var on_server_start_packet :OnServerStart
var id_assignment_packet: IDAssignment
func _ready() -> void:
	NetworkHandler.on_peer_connected.connect(on_peer_connected)
	NetworkHandler.on_peer_disconnected.connect(on_peer_disconnected)

	NetworkHandler.on_server_packet.connect(on_server_packet)

func on_peer_connected (peer_id: int) -> void:
	peer_ids.append(peer_id)
	
	id_assignment_packet = IDAssignment.create(peer_id,0,2, peer_ids, [], [])
	#send map data over the network 
	on_server_start_packet.send(NetworkHandler.client_peers[peer_id])
	
func on_peer_disconnected(peer_id : int) -> void:
	peer_ids.erase(peer_id)
	#optional ID-unassignment type and broadcast to still connected players that that id isn't there anymore

func on_server_packet(peer_id: int, data: PackedByteArray) -> void:
	var packet_type : int = data.decode_u8(0)
	
	match packet_type:
		PacketInfo.PACKET_TYPE.ID_ASSIGNMENT:
			var type_packet = IDAssignment.create_from_data(data)
			
			id_assignment_packet.plane_type = type_packet.plane_type
			
			peer_types.append(type_packet.plane_type)
			peer_states.append(type_packet.state)
			id_assignment_packet.remoted_types = peer_types
			id_assignment_packet.remoted_states = peer_states
			id_assignment_packet.broadcast(NetworkHandler.connection)
			print("server broadcasted plane id:", id_assignment_packet.id,"type:", id_assignment_packet.plane_type)
			id_assignment_packet = null
		PacketInfo.PACKET_TYPE.PLAYER_POSITION:
			handle_player_position.emit(peer_id, PlayerPosition.create_from_data(data))
		PacketInfo.PACKET_TYPE.SHOOT:
			Shoot.create_from_data(data).broadcast(NetworkHandler.connection)
			
		PacketInfo.PACKET_TYPE.HIT:
			Hit.create_from_data(data).broadcast(NetworkHandler.connection)
		PacketInfo.PACKET_TYPE.RESPAWN:
			Respawn.create_from_data(data).broadcast(NetworkHandler.connection)
		PacketInfo.PACKET_TYPE.UPDATESTATE:
			var update_state= UpdateState.create_from_data(data)
			peer_states[update_state.id] = update_state.state
		_:
			push_error("packet type with index", data[0], "unhandled")

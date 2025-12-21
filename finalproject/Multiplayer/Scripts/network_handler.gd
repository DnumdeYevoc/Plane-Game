extends Node

#server signals
signal on_peer_connected(peer_id:int)
signal on_peer_disconnected(peer_id:int)
signal on_server_packet(peer_id:int, data: PackedByteArray)

#client signals
signal on_connected_to_server()
signal on_disconnected_to_server()
signal on_client_packet(data: PackedByteArray)

#server variables
var available_peer_ids: Array = range(255, -1, -1) #available ids
var client_peers: Dictionary [int, ENetPacketPeer] #list of peers with ids as key

#client variables
var server_peer : ENetPacketPeer

#general variables
var connection : ENetConnection
var is_server : bool = false

var cur_ip :="192.168.2.249"
#"172.16.1.244" #school wifi  
#"192.168.2.249" #home wifi 

func _process(delta: float) -> void:
	if connection == null: return
	handle_events() #handle incoming packets

func handle_events() -> void:
	var packet_event: Array = connection.service() #this recives array with event info and is for handling connections disconnections and packets
	var event_type : ENetConnection.EventType = packet_event[0]
	
	while event_type != ENetConnection.EVENT_NONE:
		var peer: ENetPacketPeer = packet_event[1]
		match event_type:
			ENetConnection.EVENT_ERROR:
				push_warning("package resulted in unknown error")
				return
			ENetConnection.EVENT_CONNECT:
				if is_server:
					peer_connected(peer)
				else:#if client
					connected_to_server()
			ENetConnection.EVENT_DISCONNECT:
				if is_server:
					peer_disconnected(peer)
				else:#if client
					disconnected_from_server()
					return #becuase connection was set to null
			ENetConnection.EVENT_RECEIVE:
				if is_server:
					on_server_packet.emit(peer.get_meta("id"), peer.get_packet())
				else: #client 
					on_client_packet.emit(peer.get_packet())
		#call service() again to handle remaining packets in current while loop
		packet_event = connection.service()
		event_type = packet_event[0]

func start_server(ip_adress: String = cur_ip , port : int = 42069):
	connection = ENetConnection.new()
	var error : Error = connection.create_host_bound(ip_adress,port)
	if error:
		print("Server starting failed" , error_string(error))
		connection = null
		return
	ServerNetworkGlobals.on_server_start_packet = OnServerStart.create(ServerNetworkGlobals.map_id, ServerNetworkGlobals.seed)
	get_node("/root/Game/Network_UI").visible = false#ADD SPECTATING MODE HERE?
	print("server started")
	is_server = true

func peer_connected(peer: ENetPacketPeer) -> void:
	var peer_id: int = available_peer_ids.pop_back()
	peer.set_meta("id", peer_id)
	client_peers[peer_id]= peer
	
	print("peer_connected with id:", peer_id)
	on_peer_connected.emit(peer_id)

func peer_disconnected(peer: ENetPacketPeer) -> void:
	var peer_id : int = peer.get_meta("id")
	available_peer_ids.push_back(peer_id)
	client_peers.erase(peer_id)
	
	print("Successfully Disconnected", peer_id, "from server!")
	on_peer_disconnected.emit(peer_id)
	
func start_client(ip_adress: String = cur_ip, port : int = 42069):
	connection = ENetConnection.new()
	var error : Error = connection.create_host(1)
	if error:
		print("Client starting failed" , error_string(error))
		connection = null
		return
	print("client started")
	#variable for server from perspectove of clients
	server_peer = connection.connect_to_host(ip_adress, port)
	
func disconnect_client() -> void: #When player hits disconnect button
	if is_server: return
	server_peer.peer_disconnect()
	#happens automatically if you close, but this is nice if you want main screen again

func connected_to_server() -> void:
	print("Successfully connected to server")
	on_connected_to_server.emit()
	
func disconnected_from_server() -> void:
	print("successfully disconnected from server")
	on_disconnected_to_server.emit()
	connection = null

extends Node

const PLANE = preload("res://Scenes/plane.tscn")

func _ready() -> void:
	#for server
	NetworkHandler.on_peer_connected.connect(spawn_player)
	#for person who connected
	ClientNetworkGlobals.handle_local_id_assignment.connect(spawn_player)
	#for player who is already connected
	ClientNetworkGlobals.handle_remote_id_assignment.connect(spawn_player)
	
func spawn_player(id: int) -> void:
	#need to make specific spawning locations
	var player = PLANE.instantiate()
	player.owner_id = id
	player.plane_type = player.plane_resource_list[ClientNetworkGlobals.plane_ids[id]]#NEED TO ADD REMOTE PLANE_IDS LIKE PERSON_IDS
	#player.name = str(id) #optional
	
	call_deferred("add_child",player)

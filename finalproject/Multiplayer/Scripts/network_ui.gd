extends Control
@onready var start_server: Button = $ServerButtons/StartServer
@onready var join_server_container: HBoxContainer = $JoinServerContainer

@onready var client_buttons: HBoxContainer = $ClientButtons
@onready var server_buttons: HBoxContainer = $ServerButtons

@onready var seed_button: Button = $"ServerButtons/Randomize Seed"
@onready var world: Node3D = $"../World"
@onready var player_spawner : Node = $"../player_spawner"
@onready var map_list: MenuButton = $MapList
@onready var plane_selector: MenuButton = $PlaneSelector
@onready var plane_display: SubViewport = $SubViewportContainer/PlaneDisplay

@onready var spectate: Button = $ClientButtons/Spectate
@onready var respawn: Button = $ClientButtons/Respawn

var plane_type : int = -1
var spectate_id : int = 0

func _ready() -> void:
	plane_type = 0
	seed_button.text = "Randomize Seed"
	map_list.get_popup().id_pressed.connect(on_world_popup_pressed)
	plane_selector.get_popup().id_pressed.connect(on_plane_popup_pressed)
	ClientNetworkGlobals.on_death.connect(on_death)
	ClientNetworkGlobals.respawn.connect(remote_respawn)
	set_plane_popup()
	
func set_popup():
	#handle map drop down after world loads
	for map in world.map_resource_list:
		map_list.get_popup().add_item(map.name, map.id)
	
func set_plane_popup():
	for plane in ClientNetworkGlobals.plane_resource_list:
		plane_selector.get_popup().add_item(plane.name, plane.id)
	
func on_world_popup_pressed(id):
	#change display
	world.set_map_type(id)
	
func on_plane_popup_pressed(id):
	#change display
	plane_type= id
	
	plane_display.set_resource(id)
	plane_display.update_display()

func _on_start_server_pressed() -> void:
	NetworkHandler.start_server(NetworkHandler.my_ip)
	var join_ip_text := LineEdit.new()
	join_ip_text.position = Vector2(50,50)
	join_ip_text.text= str("IP : ", NetworkHandler.my_ip)
	join_ip_text.theme = load("res://Textures/new_theme.tres")
	join_ip_text.editable = false
	join_ip_text.expand_to_text_length = true
	add_sibling(join_ip_text)
	queue_free()

	

func _on_join_server_client_pressed() -> void:
	NetworkHandler.plane_type = plane_type
	NetworkHandler.start_client(NetworkHandler.server_ip)
	
	visible = false

func _on_randomize_seed_pressed() -> void:
	var map_seed = randi_range(0, 99999999)
	seed_button.text = "World seed: " + str(map_seed)
	#change seed
	world.change_seed(map_seed)

func on_death()->void:
	visible = true
	map_list.visible = false
	server_buttons.visible = false
	client_buttons.visible = true
	join_server_container.visible = false
	spectate.visible = true
	respawn.visible = true

	

func _on_spectate_pressed() -> void:
	spectate.text = "Spectate Next"
	if spectate_id <= player_spawner.get_child_count()-1:
		var player = player_spawner.get_child(spectate_id)
		player.cam.current = true
		spectate_id += 1
	else:
		spectate_id = 0


func _on_respawn_pressed() -> void:
	player_spawner.spawn_player(ClientNetworkGlobals.id, plane_type)
	Respawn.create(ClientNetworkGlobals.id, plane_type).send(NetworkHandler.server_peer)
	visible  = false

func remote_respawn(id,type)->void:
	player_spawner.spawn_player(id, type)


func _on_server_i_ptext_text_changed(new_text: String) -> void:
	NetworkHandler.server_ip = new_text

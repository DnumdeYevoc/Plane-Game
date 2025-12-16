extends Control
@onready var start_server: Button = $VBoxContainer/StartServer
@onready var join_server: Button = $VBoxContainer/JoinServer

@onready var seed_button: Button = $"VBoxContainer/Randomize Seed"
@onready var world: Node3D = $"../World"
@onready var map_list: MenuButton = $VBoxContainer/MapList

func _ready() -> void:
	seed_button.text = "Randomize Seed"
	
	update_ui()
	
	map_list.get_popup().id_pressed.connect(on_popup_pressed)
	ClientNetworkGlobals.on_server_started.connect(update_ui) #client side management 
	
func set_popup():
	#handle map drop down after world loads
	for map in world.map_resource_list:
		map_list.get_popup().add_item(map.name, map.id)
		
func on_popup_pressed(id):
	#change display
	world.set_map_type(id)
	#update var for starting server packet
	update_ui()

func _on_start_server_pressed() -> void:
	NetworkHandler.start_server()
	ClientNetworkGlobals.server_started = true
	update_ui()


func _on_join_server_client_pressed() -> void:
	NetworkHandler.start_client()
	visible = false

func _on_randomize_seed_pressed() -> void:
	var seed = randi_range(0, 999999999)
	seed_button.text = "World seed: " + str(seed)
	#change seed

func update_ui():
	if ClientNetworkGlobals.server_started:
		start_server.visible = false
		map_list.visible = false
		seed_button.visible = false
		join_server.visible = true
	
	else:
		start_server.visible = true
		map_list.visible = true
		seed_button.visible = true
		join_server.visible = false

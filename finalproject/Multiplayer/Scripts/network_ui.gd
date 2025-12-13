extends Control
@onready var start_server: Button = $VBoxContainer/StartServer
@onready var join_server: Button = $VBoxContainer/JoinServer

@onready var seed_button: Button = $"VBoxContainer/Randomize Seed"
@onready var world: Node3D = $"../World"


func _ready() -> void:
	seed_button.text = "Randomize Seed"
	
	if ClientNetworkGlobals.server_started: #IMPLIMENT THIS BY MAKING A NEW PACKET THAT SENDS WHEN THE WORLD STARTS (SENDS RESOURCE ID AND SEED)
		start_server.visible = false
	else:
		start_server.visible = true

func _on_start_server_pressed() -> void:
	NetworkHandler.start_server()
	#NEED TO MAKE INPIT FOR IP ADRESS AND SEED
	#NEEDS TO ONLY SHOW UP WHEN YOU HAVE A SERVER TO GO TO

func _on_join_server_client_pressed() -> void:
	NetworkHandler.start_client()
	visible = false

func _on_randomize_seed_pressed() -> void:
	var seed = randi_range(0, 999999999)
	seed_button.text = "World seed: " + str(seed)
	#change seed
	world.change_seed(seed)

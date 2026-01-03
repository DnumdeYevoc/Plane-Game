extends Control
@onready var start_server: Button = $VBoxContainer/StartServer
@onready var join_server: Button = $VBoxContainer/JoinServer

@onready var seed_button: Button = $"VBoxContainer/Randomize Seed"
@onready var world: Node3D = $"../World"
@onready var map_list: MenuButton = $VBoxContainer/MapList
@onready var plane_selector: MenuButton = $VBoxContainer/PlaneSelector
@onready var plane_display: SubViewport = $VBoxContainer/SubViewportContainer/PlaneDisplay

var plane_type = 0
func _ready() -> void:
	seed_button.text = "Randomize Seed"
	map_list.get_popup().id_pressed.connect(on_world_popup_pressed)
	plane_selector.get_popup().id_pressed.connect(on_plane_popup_pressed)
	set_plane_popup()
func set_popup():
	#handle map drop down after world loads
	for map in world.map_resource_list:
		map_list.get_popup().add_item(map.name, map.id)
	
func set_plane_popup():
	for plane in plane_display.plane_resource_list:
		plane_selector.get_popup().add_item(plane.name, plane.id)
	
func on_world_popup_pressed(id):
	#change display
	world.set_map_type(id)
	
func on_plane_popup_pressed(id):
	#change display
	plane_display.set_resource(id)
	plane_display.update_display()

func _on_start_server_pressed() -> void:
	NetworkHandler.start_server()

func _on_join_server_client_pressed() -> void:
	NetworkHandler.start_client(plane_type)
	
	visible = false

func _on_randomize_seed_pressed() -> void:
	var seed = randi_range(0, 99999999)
	seed_button.text = "World seed: " + str(seed)
	#change seed
	world.change_seed(seed)

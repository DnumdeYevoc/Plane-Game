extends Node3D

const collision_chunk_scene = preload("res://Scenes/collision_chunk.tscn")

@export var map_resource : Resource

@onready var mesh: MeshInstance3D = $Mesh
@onready var array_mesh := ArrayMesh.new()

@onready var collision_chunk_manager: StaticBody3D = $CollsionChunkManager
@onready var water:  = $Water
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var sun: DirectionalLight3D = $Sun
@onready var border: StaticBody3D = $Border


var noise : Noise
var size : Vector2i
var resolution : int
var height : int
var mountain_height : int
var steepness : float
var material : ShaderMaterial

var fog_color : Color
var fog_density :float

var environment : Environment 
@onready var network_ui: Control = $"../Network_UI"

#map list
#make sure in order of map.id
var map_resource_list : Array = [
	preload("res://Resources/Maps/0_beach.tres"),
	preload("res://Resources/Maps/1_grass.tres"),
	preload("res://Resources/Maps/2_volcano.tres"),
	preload("res://Resources/Maps/3_stone.tres"),
	preload("res://Resources/Maps/4_snow.tres"),
	preload("res://Resources/Maps/5_swamp.tres")
]

func _ready() -> void:
	network_ui.set_popup()
	environment = world_environment.get_environment()
	set_resource_var()
	noise.seed = randi_range(0,99999999)
	#for map syncing
	ServerNetworkGlobals.map_seed = noise.seed
	ServerNetworkGlobals.map_id = map_resource.id
	generate_mesh()
	
	

		
func set_map_type(id: int)-> void:
	map_resource = map_resource_list[id]
	map_resource.noise.seed = noise.seed
	#for map_sync
	ServerNetworkGlobals.map_id = id
	set_resource_var()
	regenerate_mesh()
	
func set_resource_var() -> void:
	#set resource var
	size = map_resource.size
	resolution =size.x/4
	
	noise = map_resource.noise
	height = map_resource.height_of_details
	mountain_height = map_resource.mountain_height
	steepness = map_resource.steepness
	material = map_resource.material
	material.set_shader_parameter("height",mountain_height*8 )
	fog_color = map_resource.fog_color
	fog_density = map_resource.fog_density
	
	water.scale  =Vector3( size.x,1, size.y)*3 
	var water_mesh_mat = water.get_child(0).mesh.surface_get_material(0)
	water_mesh_mat.albedo_color = map_resource.water_color
	if map_resource.water_glow_strength >0:
		water_mesh_mat.emission_enabled = true
		water_mesh_mat.emission_energy_multiplier = map_resource.water_glow_strength 
		water_mesh_mat.emission= map_resource.water_color
	else:
		water_mesh_mat.emission_enabled = false
	
	environment.sky.sky_material = map_resource.sky_material
	sun.light_energy = map_resource.sun_strength
	sun.light_color = map_resource.sun_color
	if fog_density >0:
		environment.fog_enabled = true
		environment.fog_density = fog_density
		environment.fog_light_color = fog_color
	else:
		environment.fog_enabled = false

	
func generate_mesh():
	#texture mesh
	var plane := PlaneMesh.new()
	plane.subdivide_depth = resolution 
	plane.subdivide_width = resolution
	plane.size = size
	
	var plane_arrays := plane.get_mesh_arrays()
	var vertex_array : PackedVector3Array= plane_arrays[ArrayMesh.ARRAY_VERTEX]
	var tangent_array : PackedFloat32Array= plane_arrays[ArrayMesh.ARRAY_TANGENT]
	for i:int in vertex_array.size():
		var vertex = vertex_array[i]
		var normal = Vector3.UP
		var tangent = Vector3.RIGHT
		if noise:
			var global_pos = Vector2(vertex.x+position.x,vertex.z+position.z)
			vertex.y = noise.get_noise_2d(global_pos.x,global_pos.y) * height
			#make mountain
			vertex.y -= steepness*abs( global_pos.x)-mountain_height
			vertex.y -= steepness*abs( global_pos.y)-mountain_height
			
			tangent = normal.cross(Vector3.UP)
			
			if vertex.y <= 0:
				vertex.y = 0
				normal = Vector3.UP
				tangent = Vector3.RIGHT
				
		vertex_array[i]= vertex
		
		tangent_array[4*i]= tangent.x
		tangent_array[4*i+1]= tangent.y
		tangent_array[4*i+2]= tangent.z
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_arrays)
	
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(array_mesh,0)
	for face_ind in range(mdt.get_face_count()):
		var normal = mdt.get_face_normal(face_ind)
		for vertex_ind in range(3):
			var vertex_id = mdt.get_face_vertex(face_ind, vertex_ind)
			mdt.set_vertex_normal(vertex_id, normal)
	array_mesh.clear_surfaces()
	mdt.commit_to_surface(array_mesh)
	
	mesh.mesh = array_mesh
	mesh.mesh.surface_set_material(0, material)
	
	var chunk_size = 50
	var chunk_amount = size/chunk_size
	for x in chunk_amount.x:
		for y in chunk_amount.y:
			var chunk = collision_chunk_scene.instantiate()
			chunk.world_height = height
			chunk.world_resolution = resolution
			chunk.world_steepness = steepness
			chunk.world_mountain_height = mountain_height
			chunk.world_size = size
			chunk.world_noise = noise
			chunk.chunk_amount = chunk_amount
			chunk.position = (Vector3(x,0,y)*chunk_size)-(Vector3(size.x, 0, size.y)/2)+ (Vector3(chunk_size,0, chunk_size)/2)
			collision_chunk_manager.add_child(chunk)

func change_seed(map_seed) -> void:
	noise.seed = map_seed
	#for map syncing
	ServerNetworkGlobals.map_seed = map_seed
	regenerate_mesh()

func set_seed_and_id(map_seed, id):
	noise.seed = map_seed
	#for map syncing
	#do both change_seed() and set_map_id() just without double generating
	ServerNetworkGlobals.map_seed = map_seed
	ServerNetworkGlobals.map_id = id
	map_resource = map_resource_list[id]
	map_resource.noise.seed = noise.seed
	#for map_sync
	set_resource_var()
	
	regenerate_mesh()

func regenerate_mesh() -> void:
	for child in collision_chunk_manager.get_children():
		collision_chunk_manager.remove_child(child)
	mesh.mesh  = null
	array_mesh = ArrayMesh.new()
	generate_mesh()
	
#func _physics_process(delta: float) -> void:
	#day night cycle
	#sun.rotation.x+=delta**2
	#not implemented becuase would have to sync times

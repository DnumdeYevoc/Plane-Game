extends Node3D

const collision_chunk_scene = preload("res://Scenes/collision_chunk.tscn")

@export var map_resource : Resource

@onready var mesh: MeshInstance3D = $Mesh
@onready var array_mesh := ArrayMesh.new()

@onready var collision_chunk_manager: StaticBody3D = $CollsionChunkManager
@onready var water:  = $Water
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var sun: DirectionalLight3D = $DirectionalLight3D


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

func _ready() -> void:
	size = map_resource.size
	mesh
	water.scale  =Vector3( size.x,0.5, size.y)*3

	#MAKE MESH REPEAT 
	noise = map_resource.noise
	noise.seed = randi_range(0,999999999)
	resolution =size.x/2
	height = map_resource.height_of_details
	mountain_height = map_resource.mountain_height
	steepness = map_resource.steepness
	material = map_resource.material
	material.set_shader_parameter("height",height*5 )
	
	environment = world_environment.get_environment()
	fog_color = map_resource.fog_color
	fog_density = map_resource.fog_density
	
	environment.sky.sky_material = map_resource.sky_material
	if fog_density >0:
		environment.volumetric_fog_enabled = true
		environment.volumetric_fog_density = fog_density
		environment.volumetric_fog_albedo = fog_color
	
	generate_mesh()
	#if adding chunk system add arguments to this function

func generate_mesh():
	#texture mesh
	var plane := PlaneMesh.new()
	plane.subdivide_depth = resolution 
	plane.subdivide_width = resolution
	plane.size = size
	
	var plane_arrays := plane.get_mesh_arrays()
	var vertex_array : PackedVector3Array= plane_arrays[ArrayMesh.ARRAY_VERTEX]
	var normal_array : PackedVector3Array= plane_arrays[ArrayMesh.ARRAY_NORMAL]
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
			
			normal = get_normal(global_pos.x ,global_pos.y)
			tangent = normal.cross(Vector3.UP)
			
			if vertex.y <= 0:
				vertex.y = 0
				normal = Vector3.UP
				tangent = Vector3.RIGHT
				
		vertex_array[i]= vertex
		normal_array[i] = normal
		tangent_array[4*i]= tangent.x
		tangent_array[4*i+1]= tangent.y
		tangent_array[4*i+2]= tangent.z
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_arrays)
	mesh.mesh = array_mesh
	mesh.mesh.surface_set_material(0, material)
	var chunk_size = 100
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
	#MAKE THIS CHUNK BASED
	
func get_normal(x: float, y:float) -> Vector3:
		var epsilon = size.x / resolution
		var normal := Vector3(
			(noise.get_noise_2d(x+epsilon, y) * height- noise.get_noise_2d(x-epsilon, y) * height)/ (2*epsilon), 
			1,
			(noise.get_noise_2d(x, y+epsilon) * height - noise.get_noise_2d(x, y-epsilon) * height) / (2*epsilon),
		)
		return normal.normalized()

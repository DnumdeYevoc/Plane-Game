extends CollisionShape3D

@onready var col_mesh := ArrayMesh.new()
@onready var player_spawner: Node

var margin := 50
var world_height :int
var world_resolution :int
var world_steepness :float
var world_mountain_height: int
var world_size : Vector2i
var world_noise : Noise
var chunk_amount: Vector2i
var player : CharacterBody3D 
var chunk_size : Vector2i

func _ready() -> void:
	ClientNetworkGlobals.on_death.connect(on_death)
	ClientNetworkGlobals.on_spawn.connect(on_spawn)
	disabled = true
	chunk_size = world_size/chunk_amount
	generate_mesh()
	player_spawner = get_node("/root/Game/player_spawner")

func generate_mesh():
	#collision mesh
	var col_plane := PlaneMesh.new()
	col_plane.subdivide_depth = (world_resolution/2)/chunk_amount.y
	col_plane.subdivide_width = (world_resolution/2)/chunk_amount.x
	col_plane.size = chunk_size
	var col_arrays := col_plane.get_mesh_arrays()
	var col_vertex_array : PackedVector3Array= col_arrays[ArrayMesh.ARRAY_VERTEX]
	
	for i:int in col_vertex_array.size():
		var col_vertex = col_vertex_array[i]
		var global_pos = Vector2(col_vertex.x+position.x,col_vertex.z+position.z)
		if world_noise:
			col_vertex.y = world_noise.get_noise_2d(global_pos.x,global_pos.y) * world_height
			#make mountain
			col_vertex.y -= world_steepness*abs( global_pos.x)-world_mountain_height
			col_vertex.y -= world_steepness*abs( global_pos.y)- world_mountain_height
			
			if col_vertex.y <= 0:
				col_vertex.y = 0
		col_vertex_array[i]= col_vertex
	
	col_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, col_arrays)
	shape = col_mesh.create_trimesh_shape()

func _physics_process(_delta: float) -> void:
	#if within chunk + margin

	if player== null:
		return
	if player.global_position.x >= (position.x-chunk_size.x/2) -margin and player.global_position.x <= (position.x + chunk_size.x/2)  + margin and player.global_position.z >= (position.z -chunk_size.y/2) - margin and player.global_position.z<= (position.z + chunk_size.y/2) + margin:
		disabled = false
	else:
		disabled = true

func on_death()->void:
	player = null

func on_spawn(p)-> void:
	player = p

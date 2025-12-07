extends StaticBody3D



@export var map_resource : Resource

@onready var mesh: MeshInstance3D = $Mesh
@onready var array_mesh := ArrayMesh.new()
@onready var collision: CollisionShape3D = $Collision
@onready var water: MeshInstance3D = $Water

var noise : Noise
var size : Vector2i
var resolution : int
var height : int
var mountain_height : int
var steepness : float
var material : ShaderMaterial
func _ready() -> void:
	
	size = map_resource.size
	water.mesh.size = size
	noise = map_resource.noise
	noise.seed = randi_range(0,999999999)
	resolution = map_resource.resolution
	height = map_resource.height_of_details
	mountain_height = map_resource.mountain_height
	steepness = map_resource.steepness
	material = map_resource.material
	material.set_shader_parameter("height",height*4 )
	
	generate_mesh()
	#if adding chunk system add arguments to thsi function

#old code
func generate_mesh():
	
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
			
			#normal = get_normal(global_pos.x ,global_pos.y)
			tangent = normal.cross(Vector3.UP)
		vertex_array[i]= vertex
	
		normal_array[i] = normal
		tangent_array[4*i]= tangent.x
		tangent_array[4*i+1]= tangent.y
		tangent_array[4*i+2]= tangent.z
		
	#MAKE STUFF BELOW WATER NOT RENDER
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_arrays)
	mesh.mesh = array_mesh
	mesh.mesh.surface_set_material(0, material)
	
func get_normal(x: float, y:float) -> Vector3:
		var epsilon = size.x / resolution
		var normal := Vector3(
			(noise.get_noise_2d(x+epsilon, y) * height- noise.get_noise_2d(x-epsilon, y) * height)/ (2*epsilon), 
			1,
			(noise.get_noise_2d(x, y+epsilon) * height - noise.get_noise_2d(x, y-epsilon) * height) / (2*epsilon),
		)
		return normal.normalized()

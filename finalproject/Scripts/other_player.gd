extends Area3D
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

var material :StandardMaterial3D
var d_cooldown := 0

func _ready() -> void:
	mesh.mesh = BoxMesh.new()
	mesh.mesh.surface_set_material(0,StandardMaterial3D.new())
	material = mesh.mesh.surface_get_material(0)

func _process(delta: float) -> void:
	
	
	#reset color delay
	if d_cooldown > 0:
		d_cooldown -= 1
	if d_cooldown == 1:
		material.albedo_color = Color8(255,255,255,1)

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group('bullets'):
		area.end()
		#health -= damage
		material.albedo_color = Color8(100,0,0,1)
		
		#colour delay
		d_cooldown = 10

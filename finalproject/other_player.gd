extends CharacterBody3D
@onready var mesh: MeshInstance3D = $MeshInstance3D
var material :StandardMaterial3D
var d_cooldown := 0

func _ready() -> void:
	mesh.mesh = BoxMesh.new()
	mesh.mesh.surface_set_material(0,StandardMaterial3D.new())
	material = mesh.mesh.surface_get_material(0)
func hit(damage):
	#health -= damage
	material.albedo_color = Color8(100,0,0,1)
	d_cooldown = 10

func _process(delta: float) -> void:
	if d_cooldown > 0:
		d_cooldown -= 1
	if d_cooldown == 1:
		material.albedo_color = Color8(255,255,255,1)

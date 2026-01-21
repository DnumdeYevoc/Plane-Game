extends Node3D

@export var target : Node3D
@export var movement_sharpness := 12

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, target.global_position, movement_sharpness*delta)
	
	var bas = lerp(transform.basis.orthonormalized(), target.transform.basis.orthonormalized(), movement_sharpness*delta)
	transform.basis = bas.orthonormalized()

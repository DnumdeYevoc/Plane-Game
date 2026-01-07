extends Node3D

@export var target : Node3D
@export var movement_sharpness := 12

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, target.global_position, movement_sharpness*delta)
	transform.basis = (lerp(transform.basis, target.transform.basis, movement_sharpness*delta)).orthonormalized()

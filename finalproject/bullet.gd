extends MeshInstance3D
var vel : Vector3

var speed : int
var target_pos := Vector3.ZERO
var end_pos:= Vector3.ZERO
var explode : bool
var damage : int
var homing : bool
@export var resource : Resource



var dir : Vector3
var h_cooldown : int
var target : Node3D
func _ready() -> void:
	speed = resource.speed
	mesh = resource.mesh
	damage = resource.damage
	explode = resource.explode
	homing = resource.homing

func hit(tar):
	target = tar
	target_pos = tar.position
	

func _process(delta: float) -> void:
	
	if homing and target != null:
		dir = position.direction_to(target.global_position)
	elif target == null:
		dir = position.direction_to(end_pos)
	else:
		#FIX NON HOMING ??
		dir = position.direction_to(target_pos)

	
	vel = dir *speed *delta
	
	if target != null:
		if (global_position+vel).distance_to(target.global_position)<2:
			
			target.hit(damage)
			end()
			
	if (global_position+vel).distance_to(end_pos)<speed/6:
		end()
		
	position += vel

func end():
	#add explsoion animation
	if explode:
		#await
		pass
	queue_free()
	

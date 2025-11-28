extends MeshInstance3D
var vel : Vector3

var speed : int
var target_pos := Vector3.ZERO
var explode : bool
var damage : int
@export var resource : Resource

var h_cooldown : int
var target : Node3D
func _ready() -> void:
	speed = resource.speed
	mesh = resource.mesh
	damage = resource.damage
	explode = resource.explode

func _process(delta: float) -> void:
	if h_cooldown > 0:
		h_cooldown -=1
	if h_cooldown == 1:
		target.hit(damage)
	var dir = position.direction_to(target_pos) 
	vel = dir *speed
	if position.distance_to(target_pos)<speed:
		end()
	position += vel

func end():
	#add explsoion animation
	if explode:
		#await
		pass
	queue_free()
	
func hit(tar):
	var delay = position.distance_to(target_pos)/resource.speed
	h_cooldown = delay
	target = tar

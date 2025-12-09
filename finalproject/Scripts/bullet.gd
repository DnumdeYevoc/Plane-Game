extends Area3D
var vel : Vector3

@export var resource : Resource

var speed : int
var target_pos := Vector3.ZERO
var end_pos:= Vector3.ZERO

var explode : bool
var damage : int
var homing : bool

var dir : Vector3
var target : Node3D
var timer : int

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	speed += resource.speed
	mesh.mesh = resource.mesh
	damage = resource.damage
	explode = resource.explode
	homing = resource.homing
	timer = resource.lifetime*60
	collision_shape.shape = resource.collision_shape
	
func _process(delta: float) -> void:
	timer -=1
	#homing
	if homing and target != null:
		#homing
		dir = position.direction_to(target.global_position)
	elif target == null:
		#homing but no target
		dir = position.direction_to(end_pos)
	else:
		#regular
		dir = position.direction_to(target_pos)
	vel = dir *speed *delta
	
	if timer <=0:
		
		end()
	
	position += vel

func end():
	
	#add explsoion animation/ particles
	if explode:
		#await
		pass
	queue_free()
	

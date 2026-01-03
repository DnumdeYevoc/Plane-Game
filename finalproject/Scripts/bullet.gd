extends Area3D

@export var resource : Resource

var speed : int

#set position
var end_pos:= Vector3.ZERO
#follwing a person
var target : Node3D

var explode : bool
var damage : int
var homing : bool

var dir : Vector3
var vel : Vector3

var timer : int

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	speed += resource.speed
	add_child(resource.mesh.instantiate())
	damage = resource.damage
	explode = resource.explode
	homing = resource.homing
	timer = resource.lifetime*60
	collision_shape.shape = resource.collision_shape
	dir = global_position.direction_to(end_pos)
func _process(delta: float) -> void:
	timer -=1
#	if target:
#		end_pos = target.global_position
	
	vel = dir *speed *delta
	
	if timer <=0:
		
		end()
	
	global_position += vel

func end():
	
	#add explsoion animation/ particles
	if explode:
		#await
		pass
	queue_free()
	

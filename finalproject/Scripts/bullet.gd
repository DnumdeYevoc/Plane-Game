extends Area3D

@export var resource : Resource

var speed : int

#set position
var end_pos:= Vector3.ZERO
#follwing a person (homing has been removed for now)

var explode : bool
var damage : int
var homing : bool

var dir : Vector3
var vel : Vector3

var timer : int

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	add_child(resource.mesh.instantiate())
	speed += resource.speed
	damage = resource.damage
	explode = resource.explode
	homing = resource.homing
	timer = resource.lifetime*60
	collision_shape.shape = resource.collision_shape

func _process(delta: float) -> void:
	timer -=1
	
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
	

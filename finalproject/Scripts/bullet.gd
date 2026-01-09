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

var  shooter_id  : int
@onready var collision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	add_child(resource.mesh.instantiate())
	speed += resource.speed
	damage = resource.damage
	explode = resource.explode
	homing = resource.homing
	timer = resource.lifetime*60
	
	collision.shape = resource.collision_shape
	
	body_entered.connect(_on_area_3d_body_entered)

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

func _on_area_3d_body_entered(body: Node3D) -> void: #problem is this signal triggers all of them even if its just one colliding
	if body.is_in_group('bullet_collision'):
		if body.owner_id != shooter_id:
			if body.is_authority:
				
				body.take_damage(damage)
				end()
			end()

extends Area3D

@export var resource : Resource

var speed : int

#set position
var end_pos:= Vector3.ZERO
#follwing a person (homing has been removed for now)

var explode : bool
var damage : int
var homing : bool
var grav : bool

var dir : Vector3
var vel : Vector3

var timer : int

var  shooter_id  : int
@onready var collision: CollisionShape3D = $CollisionShape3D
var exploding := false
func _ready() -> void:
	add_child(resource.mesh.instantiate())
	speed += resource.speed
	damage = resource.damage
	explode = resource.explode
	homing = resource.homing
	timer = resource.lifetime*60
	grav = resource.gravity
	collision.shape = resource.collision_shape.duplicate()
	
	body_entered.connect(_on_area_3d_body_entered)
	if resource.particles !=null:
		add_child(resource.particles.instantiate())

func _process(delta: float) -> void:
	if exploding == false: 
		timer -=1
		
		vel = dir *speed *delta
		if grav:
			vel.y -= 9.8*delta*2
			
		if timer <=0:
			end()
		global_position += vel
		
func end():
	#add explsoion animation/ particles
	if explode:
		print('explode')
		
		exploding = true
		#collision
		collision.shape.radius *= 4 #explosion strength variable?
		 #make it check more area to get triggered to explode easier
		#mesh
		get_child(1).visible = false
		var explosion= resource.explosion_particles.instantiate()
		for particle in explosion.get_children():
			particle.emitting =true
		add_child(explosion)
		await get_tree().create_timer(0.5).timeout
		collision.disabled = true
		await get_tree().create_timer(3.5).timeout
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void: #problem is this signal triggers all of them even if its just one colliding
	if body.is_in_group('bullet_collision'):
		if body.owner_id != shooter_id:
			if body.is_authority:
				body.take_damage(damage)
				end()
			end()
	else:
		end()

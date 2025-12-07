extends CharacterBody3D

@export var plane_type : Resource
#customizable variables by type
#handling
var max_speed : float
var acceleration : float
var deceleration : float

var pitch_speed : float
var yaw_speed : float
var roll_speed : float

var sharp_steering : float
var three_input_steering := true

var fov : float

#turbo
var turbo: bool
var turbo_strength : float #your turbo speed = top speed * turbo strength
var turbo_max : float
var turbo_reload_speed: float

#shooting
var shot_range : int
var pivotable_gun : bool
var barrel_amount : int
var barrel_spread : float
var bullet_type : Resource

#non-customizeable variables
var pitch_input := 0.0
var yaw_input := 0.0
var roll_input := 0.0

var cur_speed := 0.0

#children
@onready var cam: Camera3D = $"3rdPersonCam/Camera3D"
@onready var turbo_meter: ProgressBar = $TurboMeter
@onready var speed_label: Label = $Speed
@onready var fps_label: Label = $FPS
@onready var aim_cast: = $AimCast
@onready var projectile_manager: Node3D = $ProjectileManager

#scenes
@onready var bullet_scene = preload("res://Scenes/bullet.tscn")

#ultity variables
var target : Node3D

var screen_center : Vector2

var t_cooldown := 0
var h_cooldown := 0

func _ready() -> void:
	#set variables from resource
	max_speed = plane_type.max_speed
	acceleration = plane_type.acceleration
	deceleration = plane_type.deceleration
	pitch_speed = plane_type.pitch_speed
	yaw_speed = plane_type.yaw_speed
	roll_speed = plane_type.roll_speed
	sharp_steering = plane_type.sharp_steering
	three_input_steering = plane_type.three_input_steering
	fov = plane_type.fov
	turbo = plane_type.turbo
	turbo_strength = plane_type.turbo_strength
	turbo_max = plane_type.turbo_max
	turbo_reload_speed = plane_type.turbo_reload_speed
	pivotable_gun = plane_type.pivotable_gun
	shot_range = plane_type.shot_range
	aim_cast.shape.radius = plane_type.aim_assist_radius
	barrel_amount = plane_type.barrel_amount
	barrel_spread = plane_type.barrel_spread
	bullet_type = plane_type.bullet_type
	
	#set other values
	cam.fov = fov
	
	max_speed /= 4
	
	if turbo:
		turbo_meter.max_value = turbo_max
		turbo_meter.size.x= turbo_max*100
		turbo_meter.value = 0.0
		t_cooldown = 100
	
	#non-pivotable settings
	if pivotable_gun == false:
		aim_cast.target_position = Vector3(0,0,-shot_range)
	#pivotable settings
	
	
	#set screen_center
	screen_center = cam.get_viewport().size /2.0
	get_tree().root.size_changed.connect(_on_viewport_size_changed)
func _on_viewport_size_changed():
	screen_center = cam.get_viewport().size /2.0
	
func get_input(delta):
	#speed
	if Input.is_action_pressed("speed_up"):
		cur_speed = lerp(cur_speed, max_speed, acceleration *delta)
	if Input.is_action_pressed("slow_down"):
		cur_speed = lerp(cur_speed, 0.0, deceleration *delta)
	#turbo
	if turbo:
		if t_cooldown <=0:
			if Input.is_action_pressed("turbo"):
					turbo_meter.value -= acceleration*delta
					cur_speed = lerp(cur_speed, max_speed*turbo_strength, acceleration *delta)
					cam.fov = lerp(cam.fov, fov + 20.0, acceleration*2 *delta)
					
					#if empty meter
					if turbo_meter.value <= 0:
						t_cooldown = 100
			#reload meter
			elif turbo_meter.value != turbo_meter.max_value:
				turbo_meter.value += turbo_reload_speed*delta
	#turbo cooldown
	if Input.is_action_just_released("turbo"):
		t_cooldown = 100
	if t_cooldown:
		#reverse effects
		t_cooldown -=1
		cur_speed = lerp(cur_speed, clamp(max_speed,0,cur_speed), acceleration *delta)
		cam.fov = lerp(cam.fov, fov, acceleration*4 *delta)
	if t_cooldown == 1:
		#end effects
		cur_speed = clamp(max_speed,0,cur_speed)
		cam.fov = fov
	
	#get rotation input
	pitch_input = lerp(pitch_input, Input.get_action_strength("pitch_up")-Input.get_action_strength("pitch_down"), sharp_steering*delta)
	yaw_input = lerp(yaw_input, Input.get_action_strength("yaw_left")-Input.get_action_strength("yaw_right"), sharp_steering*delta)
	
	if three_input_steering:
		roll_input = lerp(roll_input, Input.get_action_strength("roll_left")-Input.get_action_strength("roll_right"), sharp_steering*delta)
	else:
		#two input steering
		yaw_speed = 0.4*roll_speed
		roll_input = yaw_input 
	
	#hit scan shooting
	if pivotable_gun:
		#FIX DIS
		var rel_mouse_pos = (screen_center -get_viewport().get_mouse_position())/screen_center
		aim_cast.target_position = Vector3(-rel_mouse_pos.x, rel_mouse_pos.y,cam.position.z) 
		aim_cast.target_position*shot_range
		
	if Input.is_action_just_pressed("shoot"):
		#bullet
		if barrel_amount >0:
			for barrel in barrel_amount:
				var bullet = bullet_scene.instantiate()
				
				bullet.resource = bullet_type
				bullet.position = position 
				bullet.rotation = rotation
				bullet.position = to_global(to_local(bullet.position) + Vector3((barrel+0.5 - barrel_amount/2)*barrel_spread,0,0))
				bullet.end_pos =  to_global(aim_cast.target_position+Vector3((barrel+0.5 - barrel_amount/2)*barrel_spread,0,0))
				bullet.speed = cur_speed
				
				if aim_cast.is_colliding():
					target = aim_cast.get_collider(0)
					if target.is_in_group("bullet_collision"):
						bullet.shoot(target)
						
				projectile_manager.add_child(bullet)

func _physics_process(delta: float) -> void:
	#input
	get_input(delta)
	
	#UI
	speed_label.text = str(int(cur_speed*4))+ "km/h"
	fps_label.text = str(Engine.get_frames_per_second()) + "FPS"
	
	#rotate
	transform.basis = transform.basis.rotated(transform.basis.z, roll_input*roll_speed*delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input*pitch_speed*delta)
	transform.basis = transform.basis.rotated(transform.basis.y, yaw_input*yaw_speed*delta)
	transform.basis = transform.basis.orthonormalized()
	
	#move forward
	velocity = -transform.basis.z*cur_speed
	move_and_slide()

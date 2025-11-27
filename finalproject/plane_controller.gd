extends CharacterBody3D

@export var max_speed := 80.0
@export var acceleration := 0.6
@export var deceleration := 0.3

@export var pitch_speed := 1.0
@export var yaw_speed := 2.0
@export var roll_speed := 2.0

@export var sharp_steering := 8
@export var three_input_steering := true
@export var fov := 90.0

@export var turbo:= true

@export var turbo_strength:= 1.5 #your new top speed = top speed * turbo strength
@export var turbo_max:= 3.0
@export var turbo_reload_speed:= 1.0
@export var turbo_cooldown := 100

@export var shot_range := 1000
@export var shot_delay := 10
@export var shot_damage := 100
@export var aim_assist_radius := 3
@export var pivotable_gun := true

var pitch_input := 0.0
var yaw_input := 0.0
var roll_input := 0.0

var cur_speed := 0.0

@onready var cam: Camera3D = $"3rdPersonCam/Camera3D"
@onready var turbo_meter: ProgressBar = $TurboMeter
@onready var speed_label: Label = $Speed
@onready var aim_cast: = $AimCast


var target : Node3D
var t_cooldown := 0
var h_cooldown := 0
var screen_center : Vector2

func _ready() -> void:
	
	cam.fov = fov
	max_speed /= 4
	if turbo:
		turbo_meter.max_value = turbo_max
		turbo_meter.size.x= turbo_max*100
		turbo_meter.value = 0.0
		t_cooldown = turbo_cooldown
	
	
	aim_cast.shape.radius = aim_assist_radius
	
	if pivotable_gun:
		aim_cast.position.z = 0
	else:
		aim_cast.position.z = 5
		aim_cast.target_position = Vector3(0,0,-shot_range)
		
	screen_center = cam.get_viewport().size /2.0
	get_tree().root.size_changed.connect(_on_viewport_size_changed)
	
func _on_viewport_size_changed():
	screen_center = cam.get_viewport().size /2.0
	
func get_input(delta):
	if Input.is_action_pressed("speed_up"):
		cur_speed = lerp(cur_speed, max_speed, acceleration *delta)
	if Input.is_action_pressed("slow_down"):
		cur_speed = lerp(cur_speed, 0.0, deceleration *delta)
	
	#turbo
	if turbo:
		if t_cooldown ==0:
			if Input.is_action_pressed("turbo"):
					turbo_meter.value -= acceleration*delta
					print(acceleration*delta)
					cur_speed = lerp(cur_speed, max_speed*turbo_strength, acceleration *delta)
					cam.fov = lerp(cam.fov, fov + 20.0, acceleration*2 *delta)
					if turbo_meter.value <= 0:
						t_cooldown = turbo_cooldown
			elif turbo_meter.value != turbo_meter.max_value:
				turbo_meter.value += turbo_reload_speed*delta
	
	#turbo cooldown
	if Input.is_action_just_released("turbo"):
		t_cooldown = turbo_cooldown
	if t_cooldown:
		t_cooldown -=1
		cur_speed = lerp(cur_speed, clamp(max_speed,0,cur_speed), acceleration *delta)
		cam.fov = lerp(cam.fov, fov, acceleration*4 *delta)
	if t_cooldown == 1:
		cur_speed = clamp(max_speed,0,cur_speed)
		cam.fov = fov
	
	pitch_input = lerp(pitch_input, Input.get_action_strength("pitch_up")-Input.get_action_strength("pitch_down"), sharp_steering*delta)
	yaw_input = lerp(yaw_input, Input.get_action_strength("yaw_left")-Input.get_action_strength("yaw_right"), sharp_steering*delta)
	if three_input_steering:
		roll_input = lerp(roll_input, Input.get_action_strength("roll_left")-Input.get_action_strength("roll_right"), sharp_steering*delta)
	else:
		yaw_speed = 0.4*roll_speed
		roll_input = yaw_input 
	
	#hit scan shooting
	#ADD VARIABLE AMOUNTS OF GUNS
	if pivotable_gun:
		var rel_mouse_pos = (screen_center -get_viewport().get_mouse_position())/screen_center
		aim_cast.target_position = Vector3(-rel_mouse_pos.x, rel_mouse_pos.y,cam.position.z) 
		aim_cast.target_position*shot_range
	if Input.is_action_just_pressed("shoot"):
		if aim_cast.is_colliding():
			target = aim_cast.get_collider(0)
			h_cooldown = shot_delay
	if h_cooldown > 0:
		h_cooldown -=1
		
	if h_cooldown == 1:
		if target.is_in_group("bullet_collision"):
			target.hit(shot_damage)

func _physics_process(delta: float) -> void:
	#input
	get_input(delta)
	
	speed_label.text = str(int(cur_speed*4))+ "km/h"
	#rotate
	transform.basis = transform.basis.rotated(transform.basis.z, roll_input*roll_speed*delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input*pitch_speed*delta)
	transform.basis = transform.basis.rotated(transform.basis.y, yaw_input*yaw_speed*delta)
	transform.basis = transform.basis.orthonormalized()
	
	#move forward
	velocity = -transform.basis.z*cur_speed

	move_and_slide()

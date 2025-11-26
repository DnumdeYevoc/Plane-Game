extends CharacterBody3D

@export var max_speed := 50.0
@export var acceleration := 0.1
@export var deceleration := 0.2

@export var pitch_speed := 1.0
@export var yaw_speed := 1.0
@export var roll_speed := 1.0

@export var sharp_steering := 2

@export var three_input_steering := true

var pitch_input := 0.0
var yaw_input := 0.0
var roll_input := 0.0

var cur_speed := 0.0


@onready var cam: Camera3D = $"3rdPersonCam/Camera3D"

func get_input(delta):
	if Input.is_action_pressed("speed_up"):
		cur_speed = lerp(cur_speed, max_speed, acceleration *delta)
		if cur_speed/20.0 >= 1:
			cam.fov = lerp(cam.fov, 110.0, acceleration*delta)
	if Input.is_action_pressed("slow_down"):
		cur_speed = lerp(cur_speed, 0.0, deceleration *delta)
		if cur_speed/20.0 <= 1:
			cam.fov = lerp(cam.fov, 90.0, deceleration*delta)

	pitch_input = lerp(pitch_input, Input.get_action_strength("pitch_up")-Input.get_action_strength("pitch_down"), sharp_steering*delta)
	yaw_input = lerp(yaw_input, Input.get_action_strength("yaw_left")-Input.get_action_strength("yaw_right"), sharp_steering*delta)
	if three_input_steering:
		roll_input = lerp(roll_input, Input.get_action_strength("roll_left")-Input.get_action_strength("roll_right"), sharp_steering*delta)
	else:
		yaw_speed = 0.4*roll_speed
		roll_input = yaw_input 
func _physics_process(delta: float) -> void:
	#input
	get_input(delta)
	
	#rotate
	transform.basis = transform.basis.rotated(transform.basis.z, roll_input*roll_speed*delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input*pitch_speed*delta)
	transform.basis = transform.basis.rotated(transform.basis.y, yaw_input*yaw_speed*delta)
	transform.basis = transform.basis.orthonormalized()
	
	#move forward
	velocity = -transform.basis.z*cur_speed
	
	move_and_slide()

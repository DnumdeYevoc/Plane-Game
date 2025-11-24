extends CharacterBody3D

@export var max_speed := 80.0 #m/s
@export var min_speed := 0.0
@export var acceleration := 15.5
@export var deceleration := 10.5
@export var current_speed := 50.0

@export var yaw_speed := 45.0 #deg/s
@export var pitch_speed := 45.0
@export var roll_speed := 45.0

@onready var model: MeshInstance3D = $Model
@onready var cam:= $Camera3D
var turn_input : Vector2

var screen_center : Vector2
func _ready() -> void:
	screen_center = cam.get_viewport().size /2.0
	get_tree().root.size_changed.connect(_on_viewport_size_changed)
	
func _on_viewport_size_changed():
	screen_center = cam.get_viewport().size /2.0
	
func _physics_process(delta: float) -> void:
	turn_input = (screen_center - get_viewport().get_mouse_position()).normalized()
	var roll = Input.get_axis("A","D")
	if Input.is_action_pressed("W") and current_speed < max_speed:
		current_speed += acceleration*delta
	elif  Input.is_action_pressed("S") and current_speed > min_speed:
		current_speed -= acceleration*delta
		
	velocity = -basis.z *current_speed
	
	move_and_slide()
	
	var turn_dir = Vector3(-turn_input.y, -turn_input.x, -roll)
	apply_rotation(turn_dir,delta)
func apply_rotation(vector, delta):
	pass

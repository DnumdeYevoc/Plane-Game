extends Camera3D

#speed
@export var speed := 10.0
@export var turbo := 2.0
@export var turbo_time := 5.0
#yaw
@export var yaw_speed := 10.0
@export var max_yaw := 70
#roll
@export var max_roll := 70
#pitch
@export var pitch_speed := 10.0
@export var max_pitch := 30

@onready var model = $Model
@onready var screen_center = get_viewport().size/2.0
func _ready():
	get_tree().root.size_changed.connect(_on_viewport_size_changed)
func _on_viewport_size_changed():
	screen_center = get_viewport().size/2.0
func _process(delta: float) -> void:
	#move
	global_position -= transform.basis.z * delta * speed
	
	#need to figure out why loop de loops arent working 
	#possibly add sideways flips too
	#adjust export variables
	#add clamp on mouse pos?
	#pitch
	var rel_mouse_pos = (screen_center - get_viewport().get_mouse_position())/screen_center
	rel_mouse_pos.x = clamp(rel_mouse_pos.x, -1,1)
	rel_mouse_pos.y = clamp(rel_mouse_pos.y, -1,1)
	rotation_degrees.x += rel_mouse_pos.y *delta * pitch_speed
	model.rotation_degrees.x = lerp(0, max_pitch, abs(rel_mouse_pos.y))* sign(rel_mouse_pos.y)
	
	#yaw
	rotation_degrees.y += rel_mouse_pos.x *delta * yaw_speed
	model.rotation_degrees.y = lerp(0, max_yaw, abs(rel_mouse_pos.x))* sign(rel_mouse_pos.x)
	#roll
	model.rotation_degrees.z = lerp(0, max_roll, abs(rel_mouse_pos.x))* sign(rel_mouse_pos.x)

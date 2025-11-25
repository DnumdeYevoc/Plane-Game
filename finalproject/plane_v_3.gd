extends CharacterBody3D


var turn_input : Vector2
var screen_center : Vector2
@onready var cam: Camera3D = $Camera3D

func _ready() -> void:
	screen_center = cam.get_viewport().size /2.0
	get_tree().root.size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed():
	screen_center = cam.get_viewport().size /2.0
	
func _physics_process(delta: float) -> void:
	turn_input = (screen_center - get_viewport().get_mouse_position()).normalized()
	
	#Quaternion(to_global() - v1)
	#look_at(Vector3(turn_input.x, turn_input.y, 0.1))

extends Resource

@export var name : String
@export var id : int

#health
@export var plane_health : int
@export var player_health : int
#appearance
@export var mesh : PackedScene
@export var collision_shape : Shape3D
#handling
@export var max_speed : float #in km/h
@export var acceleration : float
@export var deceleration : float

@export var pitch_speed : float
@export var yaw_speed : float
@export var roll_speed : float

@export var sharp_steering : float
@export var three_input_steering := true

@export var fov : float

#turbo
@export var turbo_particles : PackedScene
@export var jet_amount : int #number of jet engines
@export var jet_spread : float #how far from, the centre they are
@export var jet_position : Vector2 #x,y from areil view
@export var turbo: bool
@export var turbo_strength : float #your turbo speed = top speed * turbo strength
@export var turbo_max : float
@export var turbo_reload_speed: float

#shooting
@export var aim_assist_radius : int
@export var aim_assist_range : int
@export var aim_angle : int

@export var reload_speed :int
@export var amo :int
@export_range(0,10) var barrel_amount : int
@export var barrel_spread : float
@export var bullet_type : Resource

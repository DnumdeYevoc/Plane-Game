extends Resource

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
@export var turbo: bool
@export var turbo_strength : float #your turbo speed = top speed * turbo strength
@export var turbo_max : float
@export var turbo_reload_speed: float

#shooting
@export var pivotable_gun : bool

#hitscan

@export var aim_assist_radius : int

#projectile
@export_range(0,10) var barrel_amount : int
@export var barrel_spread : float
@export var bullet_type : Resource

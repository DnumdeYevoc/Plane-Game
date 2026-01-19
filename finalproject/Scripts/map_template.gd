extends Resource

@export var name : String
@export var id : int

#noise variables
@export var noise : Noise

@export var material : ShaderMaterial

@export var size : Vector2i
@export var height_of_details : int
@export var mountain_height : int
@export var steepness : float

#environment
@export var water_color : Color
@export var water_glow_strength : float
@export var drown_damage:int

@export var sun_strength : float
@export var sun_color : Color
@export var sky_material : ProceduralSkyMaterial 
@export var fog_color : Color
@export var fog_density :float

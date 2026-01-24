extends CharacterBody3D

@export var plane_type : Resource
var plane_id: int 

var player_state : int  #Whether it is plane, person or dead. 2=plane, 1= person, 0= dead
#multiplayer variables
#whether or not you are in control of this player
var owner_id: int
var is_authority: bool: 
	get: return !NetworkHandler.is_server && owner_id == ClientNetworkGlobals.id

#customizable variables by type
#health
var plane_health : int
var player_health : int
var cur_health : int #not customizble, like cur_speed

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
var reload_speed : int
var amo : int
var plane_explosion: Resource

var barrel_amount : int
var barrel_spread : float

var bullet_id : int
var bullet_type : Resource

#non-customizeable variables
var pitch_input := 0.0
var yaw_input := 0.0
var roll_input := 0.0

var cur_speed := 0.0

var gravity := 0.1

@onready var world: Node3D = get_node("/root/Game/World")
@onready var player_spawner:Node = get_parent()
#camera
var cam_positions : Array = [Vector3(0,3,7),Vector3(0,1,-10)] #back, front, inside(to add if wanted)
var cam_index = 0
#children
@onready var cam: Camera3D = $"CameraTarget/Camera3D"
@onready var cam_target: Node3D = $"CameraTarget"
@onready var turbo_meter: TextureProgressBar = $UI/TurboMeter
@onready var speed_label: Label = $UI/Speed
@onready var ui: VBoxContainer = $UI
@onready var fps_label: Label = $UI/FPS
@onready var aim_cast: = $AimManager/AimCast
@onready var aim_manager: = $AimManager
@onready var projectile_manager: Node
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var remote_health_bar: TextureProgressBar = $Health/SubViewport/RemoteHealthBar
@onready var ui_health_bar: TextureProgressBar = $UI/UIHealthBar
var health_bar: TextureProgressBar #current health bar
@onready var reload_bar: TextureProgressBar = $ReloadBar

@onready var turbo_manager: Node3D = $TurboManager
#scenes
@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
@onready var crosshair: AnimatedSprite2D = $Crosshair
@onready var person_mesh = preload("res://Blender/Person.blend")
@onready var parachute_scene = preload("res://Blender/Parachute.blend")
@onready var generic_bullet_type = preload("res://Resources/Bullet/ground_bullet.tres")
#ultity variables
var dir := Vector3.ZERO
var g_dir :float

var random := RandomNumberGenerator.new()
var plane_mesh : Node3D
var parachute_mesh : Node3D
var parachute_on : = false
var target : Node3D
var screen_center : Vector2

var t_cooldown := 0
var h_cooldown := 0

var jump_timer :=0
var drown_timer := 0

var reloading : int = 0
var cur_amo:int =1

var cur_wall : Array[StaticBody3D]
var disable_timer : int
var immunity_timer :int =0
var immunity_length :int = 80
var immunity : bool = false

var pp_packet_timer : int

var updated_pos : Vector3
var updated_rotation_z : float
var updated_rotation_y : float
#handle multiplayer
func _enter_tree() -> void:
	ServerNetworkGlobals.handle_player_position.connect(server_handle_player_position)
	ClientNetworkGlobals.handle_player_position.connect(client_handle_player_position)
	ClientNetworkGlobals.handle_shot.connect(client_handle_shot)
	ClientNetworkGlobals.handle_hit.connect(client_handle_hit)
	
func _exit_tree() -> void:
	ServerNetworkGlobals.handle_player_position.disconnect(server_handle_player_position)
	ClientNetworkGlobals.handle_player_position.disconnect(client_handle_player_position)
	ClientNetworkGlobals.handle_shot.disconnect(client_handle_shot)
	ClientNetworkGlobals.handle_hit.disconnect(client_handle_hit)
	
func server_handle_player_position(peer_id:int, player_position: PlayerPosition)->void:
	if owner_id != peer_id: return
	
	global_position = player_position.position
	PlayerPosition.create(owner_id, global_position,  player_position.rotation_z).broadcast(NetworkHandler.connection)
	
func client_handle_player_position(player_position: PlayerPosition)-> void:
	if is_authority || owner_id != player_position.id : return
	#movement for planes other than yours
	#update rotation locally
	if player_state == 2:
		if player_position.position - global_position != Vector3.ZERO:
			transform.basis = Basis.looking_at(player_position.position- global_position, Vector3.UP)
		#update over network z rotation
		updated_rotation_z =player_position.rotation_z 
	elif player_state == 1:
		updated_rotation_y =player_position.rotation_z 
		
		
	
	#remote parachute
	if parachute_on:
		if player_position.position.y- global_position.y >=0.1:
			parachute_on = false
			remove_child(parachute_mesh)  
			
	#update pos
	updated_pos = player_position.position
	
	
func client_handle_shot(shot)-> void:
	if shot.id == owner_id and not is_authority:
		shoot_remote(shot)
func shoot_remote(shot: Shoot)-> void:
	if barrel_amount >0:
		for barrel in barrel_amount:
			#create bullet scene
			var bullet = bullet_scene.instantiate()
			bullet.position = to_global(to_local(position) + Vector3((barrel+0.5 - barrel_amount/2)*barrel_spread,0,0))
			#variables from packet
			bullet.dir = shot.dir
			bullet.speed = shot.plane_speed
			bullet.target = null
			if shot.target_id != -1:
				for player in player_spawner.get_children():
					if player.owner_id == shot.target_id:
						bullet.target = player
			
			#finish setting variables
			bullet.resource = bullet_type
			
			bullet.rotation = rotation
			bullet.shooter_id = owner_id
			#homing was here but needs to be remade
			projectile_manager.add_child(bullet)
			
func client_handle_hit(hit: Hit) -> void:
	if hit.id == owner_id and is_authority == false: 
		
		cur_health = hit.remaining_health
		
		#make explode
		update_health()
		print(owner_id,"hit, health:", cur_health, "Client:",  ClientNetworkGlobals.id)
		
func take_damage(damage) -> void:
		if immunity == false:
			cur_health -= damage
			if cur_health <= 0:
				cur_health = 0
			Hit.create(owner_id, cur_health).send(NetworkHandler.server_peer)
			update_health()
		
func update_health() -> void:
	#health bar update code 
	health_bar.value = cur_health
	if not is_authority:
		if health_bar.value ==0  or health_bar.value == health_bar.max_value:
			health_bar.visible = false
		else:
			health_bar.visible = true
	elif health_bar.value ==0:
		health_bar.visible = false
	else:
		health_bar.visible = true
	if cur_health <=0:
		player_state -= 1
		if is_authority:
			UpdateState.create(owner_id, player_state).send(NetworkHandler.server_peer)
		
		update_state()
func update_state()-> void:
		match player_state:
			1:
				#initate immune timer
				immunity_timer = immunity_length
				
				#health
				cur_health = player_health
				health_bar.max_value = player_health
				
				#set cam
				cam_target.movement_sharpness = 12
				
				#set up player 
				#SWITCH MESH
				remove_child(plane_mesh)
				add_child(person_mesh.instantiate())
				#switch collision
				collision_shape_3d.shape = CapsuleShape3D.new()
				#turn on parachute
				parachute_mesh =parachute_scene.instantiate()
				add_child(parachute_mesh)
				parachute_on = true
				#set rotation
				rotation.z = 0
				rotation.x = 0
				#turn off turbo
				turbo_manager.queue_free()
				#set aim_cast a
				aim_cast.position = Vector3(0,0,0)
				aim_manager.position = Vector3(0,0,0)
				aim_cast.target_position = Vector3(0,0, -200)
				#set gun paramters
				amo = 10
				cur_amo = 10
				reload_speed = 2
				if is_authority:
					reload_bar.max_value = amo
					reload_bar.size.x =16*amo
					reload_bar.texture_progress.region.size =Vector2( 16*amo , 16)
				barrel_amount = 1
				barrel_spread =1
				#explosion
				bullet_type = plane_explosion
				shoot()
				
				bullet_type = generic_bullet_type#change to basooka?
				#Update UI
				speed_label.queue_free()
				turbo_meter.queue_free()
				#explode stays the same
				print("human")
			0:
				cur_health =0
				print(owner_id,"is dead")
				die()
func die():
	if is_authority:
		
		ClientNetworkGlobals.on_death.emit()
		#initate respawn screen 
	else:
		pass
		#do some death animation?
	border_check()
	queue_free()
	
func _ready() -> void:
	floor_max_angle = deg_to_rad(75)
	if is_authority:
		#make ray not collider with self
		aim_cast.add_exception(self)
		#random spawn position
		global_position.y = world.map_resource.mountain_height*4
		var angle = random.randi_range(0,360)
		global_position.x = cos(deg_to_rad(angle)) * world.size.x/4
		global_position.z = sin(deg_to_rad(angle)) * world.size.y/4
		
		#set screen_center
		screen_center =  get_viewport().get_visible_rect().size/2
		get_tree().root.size_changed.connect(_on_viewport_size_changed)
		#set crosshair
		crosshair.visible = true
		crosshair.position = screen_center
		ui.visible = true
		cam.current = true
		health_bar = ui_health_bar
		
		
	else:
		ui.visible = false
		cam.current = false
		health_bar = remote_health_bar
		crosshair.visible = false
	#set variables from resource
	#add mesh
	plane_mesh = plane_type.mesh.instantiate()
	add_child(plane_mesh)
	#collision sape
	collision_shape_3d.shape = plane_type.collision_shape
	#set turbo particles
	
	for jet in plane_type.jet_amount:
		var turbo_particles=  plane_type.turbo_particles.instantiate()
		turbo_particles.position.x = (jet*2-(plane_type.jet_amount/2)) * plane_type.jet_spread
		turbo_particles.position.y = plane_type.jet_position.y
		turbo_particles.position.z = plane_type.jet_position.x
		turbo_manager.add_child(turbo_particles)
		
	#set health
	plane_health = plane_type.plane_health
	player_health = plane_type.player_health
	cur_health = plane_health
	health_bar.visible = true
	health_bar.max_value =  plane_health
	health_bar.value = plane_health
	
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

	aim_cast.shape.radius = plane_type.aim_assist_radius
	aim_manager.rotation_degrees.x = plane_type.aim_angle
	
	reload_speed = plane_type.reload_speed
	amo = plane_type.amo
	cur_amo = amo
	if is_authority: #udpate UI values
		#set reload bar
		reload_bar.max_value = amo
		reload_bar.size.x =16*amo
		reload_bar.texture_progress.region.size =Vector2( 16*amo , 16)

		
	else:
		reload_bar.visible = false
		
	plane_explosion = plane_type.plane_explosion
	barrel_amount = plane_type.barrel_amount
	barrel_spread = plane_type.barrel_spread
	bullet_type = plane_type.bullet_type
	
	update_health()
	update_state()
	
	#set other values
	cam.fov = fov
	cam.position = cam_positions[cam_index]
	
	max_speed *= 20
	#starting speed
	cur_speed = (plane_type.min_speed+1)*20
	
	projectile_manager = get_node("/root/Game/ProjectileManager") 
	
	if turbo:
		turbo_meter.max_value = turbo_max
		ui.size.x= turbo_max*10
		turbo_meter.value = 0.0
		t_cooldown = 100
	
	#set aim target pos
	aim_cast.target_position = Vector3(0,0,-plane_type.aim_assist_range)
	
func _on_viewport_size_changed():
	screen_center = get_viewport().get_visible_rect().size/2

func get_plane_input(delta):
	speed_label.text = str(int(cur_speed/20))+ "km/h"
	cam.current = true
	#check for collision with ground (crash)
	if is_on_floor():
		cur_health = 0
		#crash()
		Hit.create(owner_id,cur_health).send(NetworkHandler.server_peer)
		update_health()
		
	#speed
	if Input.is_action_pressed("speed_up"):
		cur_speed = lerp(cur_speed, max_speed, acceleration *delta)
	if Input.is_action_pressed("slow_down"):
		cur_speed = lerp(cur_speed, 0.0, deceleration *delta)
	#turbo
	if turbo:
		if t_cooldown <=0:
			if Input.is_action_pressed("turbo"):
					
					for child in turbo_manager.get_children():
						child.emitting = true
					turbo_meter.value -= acceleration*delta*10
					cur_speed = lerp(cur_speed, max_speed*turbo_strength, acceleration *delta)
					
					cam.fov = lerp(cam.fov, fov + 40.0, acceleration*2 *delta)
					if cam_index== 1:
						cam_target.movement_sharpness = 100
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
		for child in turbo_manager.get_children():
						child.emitting = false
		t_cooldown -=1
		cur_speed = lerp(cur_speed, clamp(max_speed,0,cur_speed), acceleration *delta)
		
		cam.fov = lerp(cam.fov, fov, acceleration*4 *delta)
	if t_cooldown == 1:
		#end effects
		cam_target.movement_sharpness = 12
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
	
	similar_inputs()
	
func switch_cam()->void:
	cam_index+=1
	if cam_index >=2:
		cam_index = 0
	cam.position = cam_positions[cam_index]
	if cam_index == 1:
		crosshair.visible = false
		cam.rotation_degrees.y = 180
	else:
		crosshair.visible = true
		cam.rotation_degrees.y = 0
	
func shoot() -> void:
	
	var target_pos : Vector3
	
	if barrel_amount >0:
		for barrel in barrel_amount:
			cur_amo -=1
			reload_bar.value = cur_amo 
			if cur_amo >=0 and reloading <=0:
			#create bullet scene
				var bullet = bullet_scene.instantiate()
				bullet.position = to_global(to_local(position) + Vector3((barrel+0.5 - barrel_amount/2)*barrel_spread,0,0))
				var target_id :int 
				if aim_cast.is_colliding():
					
					var collider =aim_cast.get_collider(0)
					if collider != null:
						if collider.is_in_group("player") and collider.owner_id != owner_id:
							if player_state == 2:
								target_pos = collider.global_position+Vector3((barrel+0.5 - barrel_amount/2)*barrel_spread,0,0)+((collider.velocity/bullet_type.speed)*plane_type.aim_assist_range)
							elif player_state == 1:
								target_pos = collider.global_position
							if bullet_type.homing:
								target_id = collider.owner_id
								bullet.target = collider
						else:
							target_id = -1
							target_pos = aim_manager.to_global(aim_cast.target_position+Vector3((barrel+0.5 - barrel_amount/2)*barrel_spread,0,0))
					
					else:
						target_id = -1
						target_pos = aim_manager.to_global(aim_cast.target_position+Vector3((barrel+0.5 - barrel_amount/2)*barrel_spread,0,0))
					
						
				else:
					target_id = -1
					target_pos = aim_manager.to_global(aim_cast.target_position+Vector3((barrel+0.5 - barrel_amount/2)*barrel_spread,0,0))
					
					 
				bullet.dir = bullet.position.direction_to(target_pos)
				if  bullet_type.speed !=0:
					bullet.speed = cur_speed/60
				#send packet ASAP
				if barrel == 0: #revise?>
					Shoot.create(owner_id,target_id, bullet.speed, bullet.dir).send(NetworkHandler.server_peer)
				
				#finish setting variables
				bullet.resource = bullet_type
				bullet.rotation = rotation
				bullet.shooter_id = owner_id
				
				
				projectile_manager.add_child(bullet)
			

func rotate_plane(delta)->Vector3:
	transform.basis = transform.basis.rotated(transform.basis.z, roll_input*roll_speed*delta)
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input*pitch_speed*delta)
	transform.basis = transform.basis.rotated(transform.basis.y, yaw_input*yaw_speed*delta)
	transform.basis = transform.basis.orthonormalized()
	
	#move forward
	var vel = -transform.basis.z*cur_speed*delta
	return vel
	
func get_person_input(delta) ->Vector3:
	if Input.is_action_pressed("shift"):
		cur_speed = lerp(cur_speed, 1400.0, 1.0)#sprinting speed
		fov = lerp(fov, 120.0, 1.0)
	else:
		cur_speed= 800.0#walking speed
	cam.current = true
	#turning parachute off
	if is_on_floor() and parachute_on:
		parachute_on = false
		remove_child(parachute_mesh)
			
	#rotation:
	var rel_mouse_pos= screen_center- get_viewport().get_mouse_position()
	#up/down cam rotation
	cam_target.rotation_degrees.x= rel_mouse_pos.y/5
	cam_target.rotation_degrees.x = clamp(cam_target.rotation_degrees.x, -35, 45)
	#rotation of gun aim
	aim_manager.rotation_degrees.x=rel_mouse_pos.y/3
	aim_manager.rotation_degrees.y=rel_mouse_pos.x/7
	aim_manager.rotation_degrees.x = clamp(aim_manager.rotation_degrees.x, -35, 75)
	aim_manager.rotation_degrees.y = clamp(aim_manager.rotation_degrees.y, -60, 60)
	#left right
	yaw_input = lerp(yaw_input, Input.get_action_strength("yaw_left")-Input.get_action_strength("yaw_right"), 12.0*delta)
	transform.basis = transform.basis.rotated(transform.basis.y, yaw_input*yaw_speed*delta)
	transform.basis = transform.basis.orthonormalized()
	#forward backward movement
	pitch_input = lerp(pitch_input, Input.get_action_strength("pitch_up")-Input.get_action_strength("pitch_down"), 12.0*delta)
	dir =-pitch_input* -transform.basis.z
	
	#gravity
	if not is_on_floor():
		if parachute_on:
			g_dir -= gravity/10
		else:
			g_dir -= gravity/2
	
	if Input.is_action_pressed("jump"):
		if is_on_floor():
			g_dir = 1.0
		#swimming
		if global_position.y <=14:
			g_dir =0.5
	

	similar_inputs()
	dir.y = g_dir*delta*60*800/cur_speed
	return dir
func similar_inputs()->void:
	#immunity
	immunity_timer -= 1
	if immunity_timer>0:
		immunity = true
	else:
		immunity = false
	#reload
	#auto reload
	if reloading ==0 and cur_amo ==0:
			reloading = reload_speed*60
	if reloading>0:
		reloading -=1
		
		reload_bar.value =(((reload_speed*60.0 -reloading)/(reload_speed*60.0)) * (amo))
		
	if reloading == 1:
		cur_amo = amo
		reload_bar.value =cur_amo
	#crosshair
	if aim_cast.is_colliding():
		var tar = aim_cast.get_collider(0)
		if tar != null:
			if tar.is_in_group("player"):
				crosshair.position = cam.unproject_position(tar.global_position)
				crosshair.frame = 1
	else:
		var mouse_pos = get_viewport().get_mouse_position()
		# Acheck to fix error
		if get_viewport().get_visible_rect().has_point(mouse_pos):
			crosshair.position = cam.unproject_position(aim_manager.to_global(aim_cast.target_position))
			crosshair.frame = 0
	#shooting
	if Input.is_action_just_pressed("shoot"):
		shoot()
	#handle water/ droawning
	if global_position.y <= 14:
		cur_speed *=0.9
		
		drown_timer +=1
		
		if drown_timer == 100:
			take_damage(world.map_resource.drown_damage)
			drown_timer =0
	else:
		drown_timer = 0
		
	#handle multiple camera povs
	if Input.is_action_just_pressed("SwitchCam"):
		switch_cam()
func _physics_process(delta: float) -> void:
	
	#NEED TO ADD REMOTE TURBO PARTICLES
	#if you are pilot
	if not is_authority:
		global_position = lerp(global_position,updated_pos, 0.1)
		if player_state ==2:
			rotation.z= lerp(rotation.z, updated_rotation_z, 0.1)
		elif player_state == 1:
			rotation.y= lerp(rotation.y, updated_rotation_y, 0.1)
	else:
		#input
		
		if player_state ==2:
			get_plane_input(delta)
			#rotate
			
			velocity = rotate_plane(delta)
			
			if cur_speed<plane_type.min_speed*20:
				velocity.y -= gravity*delta*(plane_type.min_speed*20-cur_speed)*50
		elif player_state == 1:
			var d = get_person_input(delta)
			velocity = d*delta*cur_speed
		#swimming
		
		move_and_slide()
		pp_packet_timer += 1
		if pp_packet_timer >= 5:
			if player_state == 2:
				PlayerPosition.create(owner_id, global_position, rotation.z).send(NetworkHandler.server_peer)
			elif player_state == 1:
				PlayerPosition.create(owner_id, global_position, rotation.y).send(NetworkHandler.server_peer)
			pp_packet_timer = 0
		#UI
		
		fps_label.text = str(Engine.get_frames_per_second()) + "FPS"
		#border
		border_check()

func border_check()-> void:
	disable_timer -=1
	if aim_cast.is_colliding():
		var wall = aim_cast.get_collider(0)
		if wall.is_in_group("border"):
			
			wall.visible = true
			disable_timer =1
			cur_wall.append(wall)
			
			
	if disable_timer <=0 and cur_wall != null:
		for w in cur_wall:
			w.visible = false
			w = null

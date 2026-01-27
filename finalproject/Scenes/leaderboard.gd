extends ItemList
const ICON = preload("res://Textures/Icon.png")
const death_message_script = preload("res://Scripts/death_message.gd")

var kill_collumn = []
func _ready() -> void:
	ServerNetworkGlobals.leaderboard_add_player.connect(add_player)
	ServerNetworkGlobals.leaderboard_on_kill.connect(on_kill)
	ServerNetworkGlobals.leaderboard_set_name.connect(set_player_name)
	ClientNetworkGlobals.client_leaderboard_on_kill.connect(on_kill)
	ClientNetworkGlobals.client_leaderboard_add_player.connect(add_player)
	ClientNetworkGlobals.client_leaderboard_set_name.connect(set_player_name)
func on_kill(killed:int, killer:int)->void:
	#death count
	var death_id =( (killed+2)*3) -1
	set_item_text(death_id,str(int(get_item_text(death_id))+1))
	#kill count
	var kill_id := -1
	if killer != 50 and killer!= killed:
		kill_id = ((killer+2)*3) -2
	
		set_item_text(kill_id,str(int(get_item_text(kill_id))+1))
	
	#check who has the most kills?
	#create death message
	death_message(death_id,kill_id)
	
func add_player(peer_ids:Array[int])-> void:
	for id in peer_ids:
		if (id+2)*3 > item_count:
			var player_name = "Player"+str(id)
			var player= add_item(player_name)
			set_item_icon(player, ICON)
			set_item_selectable(player,false)
			var kills =add_item("0")
			set_item_selectable(kills,false)
			var deaths = add_item("0")
			set_item_selectable(deaths,false)

func set_player_name(id :int, player_name : String)-> void:
	set_item_text(((id+1)*3), player_name + "  ")
	#set kill collumn
	for i in item_count:
		if i> 2 and i-1 % 3 == 0:
			kill_collumn.append(i)
	print(kill_collumn)
	
func death_message(killed_id:int, killer_id:int)->void:
	var message := LineEdit.new()
	#set message

	var killed =killed_id-2
	var killer =killer_id-1
	if killer_id == -1:
		message.text = str(str(get_item_text(killed)) + " died" )
	else:
		message.text = str(str(get_item_text(killer)) + " killed " + str(get_item_text(killed))) #add random messages?

	#set line settings
	if NetworkHandler.is_server ==true:
		message.position.y= 50
	else:
		message.position.y= size.y +10
	message.position.x = position.x +10
	message.editable = false
	message.expand_to_text_length = true
	message.theme = theme
	message.add_theme_font_size_override("font_size", 20)
	message.add_theme_constant_override("outline_size", 0)
	message.add_theme_color_override("font_color", Color.BLACK)
	message.set_script(death_message_script)
	add_sibling(message)
	

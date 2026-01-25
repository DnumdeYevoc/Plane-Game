extends ItemList
const ICON = preload("res://Textures/Icon.png")
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
	if killer != 50 and killer!= killed:
		var kill_id = ((killer+2)*3) -2
	
		set_item_text(kill_id,str(int(get_item_text(kill_id))+1))
	
	#check who has the most kills
	

	
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

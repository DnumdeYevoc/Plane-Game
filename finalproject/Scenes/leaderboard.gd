extends ItemList
const ICON = preload("res://Textures/Icon.png")
func _ready() -> void:
	ServerNetworkGlobals.leaderboard_add_player.connect(add_player)
	ServerNetworkGlobals.leaderboard_on_kill.connect(on_kill)
	ServerNetworkGlobals.leaderboard_set_name.connect(set_player_name)
	ClientNetworkGlobals.client_leaderboard_on_kill.connect(on_kill)
	ClientNetworkGlobals.client_leaderboard_add_player.connect(add_player)
	ClientNetworkGlobals.client_leaderboard_set_name.connect(set_player_name)
func on_kill(killed:int, killer:int):
	#death count
	var death_id =( (killed+2)*3) -1
	set_item_text(death_id,str(int(get_item_text(death_id))+1))
	#kill count
	if killer != 50 and killer!= killed:
		var kill_id = ((killer+2)*3) -2
	
		set_item_text(kill_id,str(int(get_item_text(kill_id))+1))
		
func add_player(peer_ids:Array[int]):
	for id in peer_ids:
		if (id+2)*3 > item_count:
			var player_name = "Player"+str(id)
			var player= add_item(player_name)
			set_item_icon(player, ICON)
			add_item("0")
			add_item("0")

func set_player_name(id :int, player_name : String)-> void:
	set_item_text(((id+1)*3), player_name + "  ")
	

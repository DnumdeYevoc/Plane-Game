extends Control


func _on_start_server_pressed() -> void:
	NetworkHandler.start_server()

func _on_join_server_client_pressed() -> void:
	NetworkHandler.start_client()

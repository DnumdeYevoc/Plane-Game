extends Node
func _process(delta: float) -> void:
	await get_tree().create_timer(4).timeout
	queue_free()

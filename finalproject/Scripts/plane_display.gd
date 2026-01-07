extends SubViewport

var plane_resource : Resource

func set_resource(id: int)-> void:
	plane_resource = ClientNetworkGlobals.plane_resource_list[id]

func _ready() -> void:
	set_resource(0)
	update_display()
	
func update_display() -> void:
	remove_child(get_children()[-1])
	var mesh = plane_resource.mesh.instantiate()
	add_child(mesh)

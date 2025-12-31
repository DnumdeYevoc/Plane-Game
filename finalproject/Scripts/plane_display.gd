extends SubViewport

var plane_resource : Resource

var plane_resource_list : Array = [
	preload("res://Resources/Planes/plane_template.tres"),
]

func set_resource(id: int)-> void:
	plane_resource = plane_resource_list[id]

func _ready() -> void:
	set_resource(0)
	update_display()
	
func update_display() -> void:
	var mesh = plane_resource.mesh.instantiate()
	add_child(mesh)

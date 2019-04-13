extends MenuButton

var map_path: String

func _pressed():
	var level: Node = preload("res://Level.tscn").instance()
	level.map_path = map_path
	
	var current_root = get_tree().get_root().get_node("Menu")
	
	get_tree().get_root().add_child(level)
	
	get_tree().get_root().remove_child(current_root)

extends MenuButton

var map_path: String

func _pressed():
	var level = get_tree().get_root().get_node("Level")
	
	level.remove_child(level.get_node("Menu"))
	level.map_path = map_path
	
	level.set_map()
extends MenuButton

var map_path: String

func _pressed():
    if get_tree().get_network_unique_id() == 1:
        var level = get_tree().get_root().get_node("Level")
    
        level.remove_child(level.get_node("Menu"))
        
        level.send_map_change(self.map_path)
        
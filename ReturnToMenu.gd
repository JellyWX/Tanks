extends MenuButton

func _pressed():
    var root: Node = get_tree().get_root().get_node("Level")
    root.remove_child(root.get_node("LevelError"))
    
    var menu: Node = preload("res://Menu.tscn").instance()
    
    root.add_child(menu)
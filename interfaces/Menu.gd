extends Node2D

func _ready():
    $JoinGame.connect("pressed", self, "join_game")
    
    var maps: Array = list_directory("res://maps/")
    
    var container: Node = get_node("Container")
    
    for map in maps:
        var button: Node = preload("res://interfaces/LoadLevel.tscn").instance()
        button.text = map
        button.map_path = "res://maps/%s" % map
        print_debug(button.map_path)
        container.add_child(button)


func list_directory(path):
    var files = []
    var dir = Directory.new()
    dir.open(path)
    dir.list_dir_begin()
    
    while true:
        var file = dir.get_next()
        
        if file == "":
            break
        elif file.ends_with(".tanks"):
            files.append(file)
    
    dir.list_dir_end()
    
    return files
    
func grab_map():
    var input: Node = get_node("URLInput")
    var url: String = input.text
    
    get_node("HTTPRequest").request(url)

func join_game():
    var level = get_tree().get_root().get_node("Level")
    
    level.remove_child(level.get_node("Menu"))
    level.map_path = "res://map2.tanks"
    
    level.set_map(false, get_node("IPInput").text)

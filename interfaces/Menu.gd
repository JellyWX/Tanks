extends Control

var public: bool = false

func _ready():
    var _err = get_node("JoinGame").connect("pressed", self, "join_game")
    
    var maps: Array = list_directory("res://maps/")

    var container: Node = get_node("Container")

    for map in maps:
        var button: Node = preload("res://interfaces/LoadLevel.tscn").instance()
        button.text = map
        button.map_path = "res://maps/%s" % map
        print_debug(button.map_path)
        container.add_child(button)


func update_network_status():
    var label = get_node("ConnectionError")
    if public:
        label.text = "Public hosting via UPnP available"
    else:
        label.text = "Public hosting limited or unavailable (UPnP not available). Check your router settings (or join a friend)"


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


func join_game():
    var level: Node = get_tree().get_root().get_node("Level")
    
    get_tree().set_network_peer(null)
    var success: bool = level.start_networking(false, get_node("IPInput").text)
    
    if not success:
        get_node("IPInput").text = ""
        get_node("ConnectionError").text = "Failed to connect to IP"
    else:
        get_node("ConnectionError").text = "Connected!"
    
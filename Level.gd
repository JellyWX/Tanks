extends Spatial

var Map = load("res://map.gd")
var map_path: String

var Host = load("res://host.gd")
var server

var menu: Node = preload("res://interfaces/Menu.tscn").instance()
var host: bool = false
var ingame: bool = false

onready var ground_gridmap: Node = get_node("GroundTiles")
onready var obstacle_gridmap: Node = get_node("Obstacles")

# Called when the node enters the scene tree for the first time.
func _ready():
    add_child(menu)

func set_map(hosting: bool, ip: String = ""):
    self.host = hosting
    
    var map: Map = Map.new()
    var error = map.load_from_file(map_path, ground_gridmap.mesh_library, obstacle_gridmap.mesh_library)
    
    if error != Map.ReadMap.OK:
        map = Map.new()
        print_debug("Error occured loading map")
        var menu = preload("res://interfaces/LevelError.tscn").instance()
        add_child(menu)
    
    else:
        map.draw_to_gridmap(ground_gridmap, obstacle_gridmap)
        
        var camera: Node = get_node("CenterCamera")
        map.position_camera(camera)
        
        map.place_tanks(self)
        
    server = Host.new(self)
    
    if self.host:
        server.start_server()
    else:
        server.start_client(ip)
        
    self.ingame = true

func _process(delta: float):
    if self.ingame:
        rpc("test_print")

remote func test_print():
    print("received RPC")
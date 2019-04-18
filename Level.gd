extends Spatial

var Map = load("res://map.gd")
var map_path: String
var map: Map

var Host = load("res://host.gd")
var server

var menu: Node = preload("res://interfaces/Menu.tscn").instance()
var host: bool = false
var ingame: bool = false

onready var ground_gridmap: Node = get_node("GroundTiles")
onready var obstacle_gridmap: Node = get_node("Obstacles")

# Called when the node enters the scene tree for the first time.
func _ready():
    menu.public = self.start_networking(true)
    
    self.map = Map.new()
    add_child(menu)
    menu.update_network_status()

func start_networking(hosting: bool, ip: String = "") -> bool:
    self.host = hosting
    
    server = Host.new(self)
    
    if self.host:
        return server.start_server()
    else:
        server.start_client(ip)
        return false
        

remote func set_map(map_path):
    map.reset(ground_gridmap, obstacle_gridmap)
    
    self.map_path = map_path
    
    var error = self.map.load_from_file(map_path, ground_gridmap.mesh_library, obstacle_gridmap.mesh_library)
    
    if error != Map.ReadMap.OK:
        map = Map.new()
        print_debug("Error occured loading map")
        var menu = preload("res://interfaces/LevelError.tscn").instance()
        add_child(menu)
    
    else:
        map.draw_to_gridmap(ground_gridmap, obstacle_gridmap)
        
        var camera: Node = get_node("CenterCamera")
        map.position_camera(camera)
    
    self.ingame = true
    
remote func place_tanks(total_players: int):
    self.map.place_tanks(self, total_players)

func _process(delta: float):
    if self.ingame:
        rpc("test_print")

remote func test_print():
    print("received RPC")
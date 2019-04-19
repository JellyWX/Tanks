extends Spatial

var Map = load("res://map.gd")
var map_path: String
var map: Map

var Host = load("res://host.gd")
var server

# main menu
var menu: Node = preload("res://interfaces/Menu.tscn").instance()
# are we hosting?
var host: bool = false
# used to tell if we're in a menu or not
var ingame: bool = false

# used to determine if a map change has been sent by the server or run on the client
var local_map_change: bool = false

onready var ground_gridmap: Node = get_node("GroundTiles")
onready var obstacle_gridmap: Node = get_node("Obstacles")

# Called when the node enters the scene tree for the first time.
func _ready():
    get_tree().connect("network_peer_connected", self, "_player_connected")
    # attempt to start a server publicly to allow users to join asap
    menu.public = self.start_networking(true)
    
    self.map = Map.new()
    add_child(menu)
    menu.update_network_status()


func _player_connected(id):
    print(id)


func start_networking(hosting: bool, ip: String = "") -> bool:
    self.host = hosting
    
    server = Host.new(self)
    
    if self.host:
        return server.start_server()
    else:
        var success: bool = server.start_client(ip)
        return success
        

func send_map_change(map_path):
    self.local_map_change = true
    var peers: PoolIntArray = get_tree().get_network_connected_peers()
    
    self.set_map(map_path)
    rpc("set_map", map_path)
    
    self.place_tanks(0)
    var e: int = 1
    for player in peers:
        rpc_id(player, "place_tanks", e)
        e += 1


remote func set_map(map_path):
    
    if self.local_map_change or get_tree().get_rpc_sender_id() == 1:
        self.map.reset(ground_gridmap, obstacle_gridmap)
        self.remove_child(self.get_node("Menu"))
        
        self.map_path = map_path
        
        var error = self.map.load_from_file(map_path, ground_gridmap.mesh_library, obstacle_gridmap.mesh_library)
        
        if error != Map.ReadMap.OK:
            self.map = Map.new()
            print_debug("Error occured loading map")
            var menu = preload("res://interfaces/LevelError.tscn").instance()
            add_child(menu)
        
        else:
            map.draw_to_gridmap(ground_gridmap, obstacle_gridmap)
            
            var camera: Node = get_node("CenterCamera")
            map.position_camera(camera)
        
        self.ingame = true
        self.local_map_change = false
    
    else:
        print_debug("Map change not permitted. I smell a cheater")
        
    
remote func place_tanks(order: int):
    self.map.place_tanks(self, order)


remote func set_position(id: int, v: Vector2, r: float):
    if id == get_tree().get_rpc_sender_id():
        var tank: Spatial = self.map.tanks[id]
        
        tank.translation.x = v.x
        tank.translation.z = v.y
        tank.set_rotation(Vector3(0, r, 0))

func update_position(tank: Node):
    rpc_unreliable("set_position", get_tree().get_network_unique_id(), Vector2(tank.translation.x, tank.translation.z), tank.rotation.y)
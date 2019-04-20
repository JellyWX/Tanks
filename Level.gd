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
    randomize()
    
    self.local_map_change = true
    var peers: PoolIntArray = get_tree().get_network_connected_peers()
    
    self.set_map(map_path)
    rpc("set_map", map_path)
    
    self.place_tanks(0, 1)
    var e: int = 1
    var pids: Array = []
    
    for player in peers:
        var pid: int = rand_range(0, 0xffffffff)
        rpc_id(player, "place_tanks", e, pid)
        e += 1
        
        self.map.tanks[player].update_code = pid


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
        
    
remote func place_tanks(order: int, priv_id: int):
    self.map.place_tanks(self, order, priv_id)


remote func set_position(v: Vector2, r: float, net_sender: int, validation: int):
    var tank: Spatial = self.map.tanks[net_sender]
    
    # if the host sends the update and the update is not regarding ourselves
    if get_tree().get_rpc_sender_id() == 1 \
        and net_sender != get_tree().get_network_unique_id():
        tank.translation.x = v.x
        tank.translation.z = v.y
        tank.set_rotation(Vector3(0, r, 0))
    
    # else if we are the host
        # does the validation they sent match the validation we gave them when we started the game
    elif get_tree().get_network_unique_id() == 1 \
        and tank.update_code == validation:
          
        # yes- redistribute their position update
        rpc_unreliable("set_position", v, r, net_sender, 0)
        
        # update their position locally
        tank.translation.x = v.x
        tank.translation.z = v.y
        tank.set_rotation(Vector3(0, r, 0))


func update_position(tank: Node):
    var nid: int = get_tree().get_network_unique_id()
    if nid != 1:
        rpc_unreliable_id(1, "set_position", Vector2(tank.translation.x, tank.translation.z), tank.rotation.y, nid, tank.update_code)
    else:
        rpc_unreliable("set_position", Vector2(tank.translation.x, tank.translation.z), tank.rotation.y, 1, 0)
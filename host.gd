class_name Host

var enet: NetworkedMultiplayerENet
var tree: SceneTree

const HOST_PORT: int = 2422

func _init(scene: Node):
    self.enet = NetworkedMultiplayerENet.new()
    
    self.tree = scene.get_tree()


func start_server() -> bool:
    var public: bool = true
    var upnp = UPNP.new()
    
    upnp.discover()
    var gateway = upnp.get_gateway()
    
    if gateway and gateway.is_valid_gateway():
        var res_udp = upnp.add_port_mapping(HOST_PORT, HOST_PORT, 'GodotGame', 'UDP')
        var res_tcp = upnp.add_port_mapping(HOST_PORT, HOST_PORT, 'GodotGame', 'TCP')
        
        if res_udp != 0 or res_tcp != 0:
            public = false
    else:
        public = false
    
    var ok: int = self.enet.create_server(HOST_PORT, 4)
    
    if ok == 0:
        self.tree.set_network_peer(self.enet)
    else:
        public = false
    
    return public
    
func start_client(ip: String) -> bool:
    var ok: int = self.enet.create_client(ip, HOST_PORT)
    
    if ok == 0:
        self.tree.set_network_peer(self.enet)
        return true
    else:
        return false
    
func start_match():
    pass

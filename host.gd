class_name Host

var enet: NetworkedMultiplayerENet
var tree: SceneTree

const HOST_PORT: int = 2422

func _init(scene: Node):
    self.enet = NetworkedMultiplayerENet.new()
    
    self.tree = scene.get_tree()
    
func start_server():
    var upnp = UPNP.new()
    upnp.discover()
    var num_devices = upnp.get_device_count()
    for i in range(num_devices):
        var upnp_device = upnp.get_device(i)
        print('device[',i,']:')
        print('- igd_our_addr: ', upnp_device.igd_our_addr)
        print('- igd_service_type: ', upnp_device.igd_service_type)
        print('- igd_status: ', upnp_device.igd_status)
        print('- service_type: ', upnp_device.service_type)
    print('gateway:', upnp.get_gateway())
    
    if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
        var res_udp = upnp.add_port_mapping(HOST_PORT, HOST_PORT, 'Godot', 'UDP')
        var res_tcp = upnp.add_port_mapping(HOST_PORT, HOST_PORT, 'Godot', 'TCP')
        print('res_udp:', res_udp)
        print('res_tcp:', res_tcp)
    else:
        print('no valid gateway')
    
    self.enet.create_server(HOST_PORT, 4)
    
    self.tree.set_network_peer(self.enet)
    
func start_client(ip: String):
    self.enet.create_client(ip, HOST_PORT)
    
    self.tree.set_network_peer(self.enet)
    
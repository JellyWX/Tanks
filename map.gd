enum ReadMap {ERR_WRONG_SIZE, ERR_FILE, ERR_WRONG_SPAWNS, OK}

const OBSTACLE_NAMES: Array = ["start", "rock1"]
const TILE_NAMES: Array = ["wall", "bumpy1", "track"]

const TILE_WIDTH: int = 8

var tanks: Dictionary = {}

class Dimensions:
    var x: int
    var y: int
    
    func _init(x: int, y: int):
        self.x = x
        self.y = y
        
    func size() -> int:
        return self.x * self.y


class GridElement:
    var type: int
    var orientation: int
    var obstacle: int
    var obstacle_orientation: int
    var spawn: bool = false
    var has_obstacle: bool = false
    
    var position: Vector2
    
    func _init(bytes_type: int, bytes_obstacle: int, ground_meshlib: MeshLibrary, obstacle_meshlib: MeshLibrary, position: Vector2):
        self.position = position
        self.type = ground_meshlib.find_item_by_name(TILE_NAMES[bytes_type & 0x3f])
        
        var quaternion = Quat(Vector3(0, 1, 0), PI * 0.5 * (bytes_type >> 6))
        self.orientation = Basis(quaternion).get_orthogonal_index()

        self.obstacle = bytes_obstacle & 0x3f >> 1 # shift to remove the trailing 0 (spawn bit) and add 1

        if bytes_obstacle == 1:
            self.spawn = true
            self.has_obstacle = true
            self.obstacle = obstacle_meshlib.find_item_by_name("start")
        
        elif self.obstacle != 0:
            self.has_obstacle = true
            self.obstacle = obstacle_meshlib.find_item_by_name(OBSTACLE_NAMES[self.obstacle - 1])

        quaternion = Quat(Vector3(0, 1, 0), PI * 0.5 * (bytes_obstacle >> 6))
        self.obstacle_orientation = Basis(quaternion).get_orthogonal_index()


class_name Map

var grid: Array
var dimensions: Dimensions

func _init():
    pass

func load_from_file(filepath: String, ground_meshlib: MeshLibrary, obstacle_meshlib: MeshLibrary):
    var level_map: File = File.new()
    var error = level_map.open(filepath, File.READ)
    
    if error != OK:
        return ReadMap.ERR_FILE
    
    else:
        var x = self.load_from_bytes(level_map, ground_meshlib, obstacle_meshlib)
        level_map.close()
        return x
        
func load_from_bytes(bytes, ground_meshlib: MeshLibrary, obstacle_meshlib: MeshLibrary):
    var spawn_count: int = 0
    
    var dimensions: Dimensions = Dimensions.new(bytes.get_8(), bytes.get_8())
    var grid: Array = []
    
    var next_byte_tile: int = bytes.get_8()
    var next_byte_object: int = bytes.get_8()
    var index: int = 0
    
    while not bytes.eof_reached():
        var position: Vector2 = Vector2(index % dimensions.x, index / dimensions.x)
        var ge = GridElement.new(next_byte_tile, next_byte_object, ground_meshlib, obstacle_meshlib, position)
        
        if ge.spawn:
            spawn_count += 1
        
        grid.append(ge)
        next_byte_tile = bytes.get_8()
        next_byte_object = bytes.get_8()
    
        index += 1
    
    if len(grid) != dimensions.size():
        return ReadMap.ERR_WRONG_SIZE
    
    elif spawn_count != 4:
        return ReadMap.ERR_WRONG_SPAWNS
    
    else:
        self.dimensions = dimensions
        self.grid = grid
        return ReadMap.OK


func draw_to_gridmap(gridmap_a: Node, gridmap_b: Node):
    
    var row: int = 0
    var col: int = 0
    var ge: GridElement
    
    for index in range(self.grid.size()):
        row = index / self.dimensions.x
        col = index % self.dimensions.x
        
        ge = self.grid[index]
        
        gridmap_a.set_cell_item(col, 0, row, ge.type, ge.orientation)
        
        if ge.has_obstacle:
            gridmap_b.set_cell_item(col, 0, row, ge.obstacle, ge.obstacle_orientation)    


func position_camera(camera: Node):
    # TODO dynamic camera height
    camera.translate_object_local(Vector3(self.dimensions.x * TILE_WIDTH * 0.5, 75, (self.dimensions.y + 7) * TILE_WIDTH * 0.5))
    camera.rotate_object_local(Vector3(1, 0, 0), -PI * 0.42)


func reset(gridmap_a: Node, gridmap_b: Node):
    var row: int
    var col: int
    
    for index in range(self.grid.size()):
        row = index / self.dimensions.x
        col = index % self.dimensions.x
        
        gridmap_a.set_cell_item(col, 0, row, 0)
        gridmap_b.set_cell_item(col, 0, row, -1)


func place_tanks(root: Node, order: int, priv_id: int):
    var players: PoolIntArray = root.get_tree().get_network_connected_peers()
    
    print(players)
    
    var spawn_number: int = 0
    var p_number: int = 0
    self.tanks.clear()
    
    for element in self.grid:
        if element.spawn:
            var tank: Node = preload("res://entities/Tank.tscn").instance()
            
            if spawn_number == order:
                tank.locally_controlled = true
                tank.controller_id = root.get_tree().get_network_unique_id()
                tank.update_code = priv_id
            else:
                tank.controller_id = players[p_number]
                p_number += 1
                
            spawn_number += 1

            tank.translation = Vector3((element.position.x + 0.5) * TILE_WIDTH, 20, (element.position.y + 0.5) * TILE_WIDTH)
            
            self.tanks[tank.controller_id] = tank
            root.add_child(tank)
            
            if spawn_number == players.size() + 1:
                break
extends Spatial

var Map = load("res://map.gd")
var map_path: String

var menu: Node = preload("res://interfaces/Menu.tscn").instance()

onready var ground_gridmap: Node = get_node("GroundTiles")
onready var obstacle_gridmap: Node = get_node("Obstacles")

# Called when the node enters the scene tree for the first time.
func _ready():
    add_child(menu)

func set_map():
    var map: Map = Map.new()
    var error = map.load_from_file(map_path, ground_gridmap.theme, obstacle_gridmap.theme)
    
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
        
func _physics_process(tdelta: float):
    pass
    
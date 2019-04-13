extends Spatial

var Map = load("res://map.gd")
var map_path: String

# Called when the node enters the scene tree for the first time.
func _ready():
	var map: Map = Map.new()
	var error = map.load_from_file(map_path)
	
	if error != Map.ReadMap.OK:
		print_debug("Error occured loading map")
		var menu = preload("res://LevelError.tscn").instance()
		add_child(menu)
	
	else:
		var ground_gridmap: Node = get_node("GroundTiles")
		map.draw_to_gridmap(ground_gridmap)
		
		var camera: Node = get_node("CenterCamera")
		map.position_camera(camera)
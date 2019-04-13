extends Spatial

var Map = load("res://map.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	var map: Map = Map.new()
	map.load_from_file("res://maps/map1.tanks")
	
	print_debug(map.dimensions)
	print_debug(map.grid)
	
	var ground_gridmap: Node = get_node("GroundTiles")
	
	var row: int = 0
	var col: int = 0
	var element: int = 0
	var orientation: int = 0
	var ge
	
	for index in range(map.grid.size()):
		row = index / map.dimensions.x
		col = index % map.dimensions.x
		
		ge = map.grid[index]
		
		ground_gridmap.set_cell_item(row, 0, col, ge.type, ge.orientation)
		
	var camera: Node = get_node("CenterCamera")
	
	camera.translate_object_local(Vector3(map.dimensions.y * 4, 75, (map.dimensions.x + 7) * 4))
	camera.rotate_object_local(Vector3(1, 0, 0), -PI * 0.42)
	
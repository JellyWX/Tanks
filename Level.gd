extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	var level_map: File = File.new()
	var _error = level_map.open("res://maps/map1.tanks", File.READ)
	
	var dimensions: Array = [level_map.get_8(), level_map.get_8()]
	var grid : Array = []
	
	var next_byte: int = level_map.get_8()
	
	while not level_map.eof_reached():
		grid.append(next_byte)
		next_byte = level_map.get_8()
		
	if len(grid) != dimensions[0] * dimensions[1]:
		print("Map file invalid")
	
	else:
		print("Map file OK. Load proceeding")
		
		print_debug(dimensions)
		print_debug(grid)
		
		var ground_gridmap: Node = get_node("GroundTiles")
		
		var row: int = 0
		var col: int = 0
		
		for index in range(grid.size()):
			row = index / dimensions[0]
			col = index % dimensions[0]
			
			ground_gridmap.set_cell_item(row, 0, col, grid[index])
			
		var camera: Node = get_node("CenterCamera")
		
		camera.translate_object_local(Vector3(dimensions[1] * 4, 75, (dimensions[0] + 7) * 4))
		camera.rotate_object_local(Vector3(1, 0, 0), -PI * 0.42)
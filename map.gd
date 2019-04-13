enum ReadMap {ERR_WRONG_SIZE, ERR_FILE, OK}

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
	
	func _init(bytes: int):
		self.type = bytes & 0x3f # bytes & 0b00111111
		
		var quaternion = Quat(Vector3(0, 1, 0), PI * 0.5 * (bytes >> 6))
		self.orientation = Basis(quaternion).get_orthogonal_index()


class_name Map

var grid: Array
var dimensions: Dimensions

func _init():
	pass

func load_from_file(filepath):
	var level_map: File = File.new()
	var error = level_map.open(filepath, File.READ)
	
	if error != OK:
		return ReadMap.ERR_FILE
	
	else:
		var dimensions: Dimensions = Dimensions.new(level_map.get_8(), level_map.get_8())
		var grid: Array = []
		
		var next_byte: int = level_map.get_8()
		
		while not level_map.eof_reached():
			var ge = GridElement.new(next_byte)
			grid.append(ge)
			next_byte = level_map.get_8()
		
		level_map.close()
		
		if len(grid) != dimensions.size():
			return ReadMap.ERR_WRONG_SIZE
		
		else:
			self.dimensions = dimensions
			self.grid = grid
			return ReadMap.OK


func draw_to_gridmap(gridmap: Node):
	
	var row: int = 0
	var col: int = 0
	var element: int = 0
	var orientation: int = 0
	var ge
	
	for index in range(self.grid.size()):
		row = index / self.dimensions.x
		col = index % self.dimensions.x
		
		ge = self.grid[index]
		
		gridmap.set_cell_item(row, 0, col, ge.type, ge.orientation)


func position_camera(camera: Node):
	camera.translate_object_local(Vector3(self.dimensions.y * 4, 75, (self.dimensions.x + 7) * 4))
	camera.rotate_object_local(Vector3(1, 0, 0), -PI * 0.42)

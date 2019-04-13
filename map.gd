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
	var _error = level_map.open(filepath, File.READ)
	
	var dimensions: Dimensions = Dimensions.new(level_map.get_8(), level_map.get_8())
	var grid: Array = []
	
	var next_byte: int = level_map.get_8()
	
	while not level_map.eof_reached():
		var ge = GridElement.new(next_byte)
		grid.append(ge)
		next_byte = level_map.get_8()
	
	if len(grid) != dimensions.size():
		return ReadMap.ERR_WRONG_SIZE
	
	else:
		self.dimensions = dimensions
		self.grid = grid
		return ReadMap.OK
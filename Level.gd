extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var level_map = File.new()
	level_map.open("res://maps/map1.tanks", File.READ)
	print(level_map.get_as_text())

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

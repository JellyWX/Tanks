extends KinematicBody

var start_time: int

func _ready():
    self.start_time = OS.get_unix_time()

func _physics_process(delta: float):
    move_and_collide(Vector3(1, 0, 0).rotated(self.rotation.normalized(), self.rotation.length()) * delta * 200)
    
    if OS.get_unix_time() - self.start_time > 5:
        self.get_parent().remove_child(self)
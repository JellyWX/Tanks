extends KinematicBody

var start_time: int

const LIFETIME: int = 5
const SPEED: int = 50

func _ready():
    self.start_time = OS.get_unix_time()

func _physics_process(delta: float):
    var collision: KinematicCollision = move_and_collide(Vector3(1, 0, 0).rotated(self.get_rotation().normalized(), self.get_rotation().length()) * delta * SPEED)
    
    if collision != null:
        var vec: Vector3 = collision.normal
        self.set_rotation(self.rotation.reflect(collision.normal))
    
    if OS.get_unix_time() - self.start_time > LIFETIME:
        self.get_parent().remove_child(self)
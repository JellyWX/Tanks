extends KinematicBody

var movement: Vector3 = Vector3(0, 0, 0)
var locally_controlled: bool = false
var controller_id: int
var moved: bool = false
var ingame: bool = false

var net_sync: Thread = Thread.new()

const SPEED: int = 550

onready var parent = get_parent()

func _ready():
    self.net_sync.start(self, "sync_position", null, 2)
    
    self.rotation = Vector3(0, 0.0001, 0)
    
    self.ingame = true

func sync_position(_none):
    while true:
        if self.ingame and self.moved:
            self.parent.update_position(self)
            self.moved = false
        OS.delay_msec(30)


func _physics_process(tdelta: float):
    if not is_on_floor():
        self.movement.y = -1
    else:
        self.movement.y = 0
        
    if self.locally_controlled:
        if is_on_floor():
            if Input.is_action_pressed("LOCAL_FORWARD"):
                self.movement.x = 1
                moved = true
            elif Input.is_action_pressed("LOCAL_BACKWARD"):
                self.movement.x = -0.6
                moved = true
            else:
                self.movement.x = 0
    
        var _collision = move_and_slide(tdelta * SPEED * self.movement.rotated(self.rotation.normalized(), self.rotation.length()), Vector3(0, 1, 0))
    
        if Input.is_action_pressed("LOCAL_LEFT"):
            rotate_tank(tdelta, 1)
            moved = true
        elif Input.is_action_pressed("LOCAL_RIGHT"):
            rotate_tank(tdelta, -1)
            moved = true
    
    else:
        var _collision = move_and_slide(tdelta * SPEED * movement, Vector3(0, 1, 0))
        

func rotate_tank(delta: float, direction: float):
    rotate_object_local(Vector3(0, 1, 0), delta * direction * PI * 0.5)
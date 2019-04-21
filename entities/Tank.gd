extends KinematicBody

var movement: Vector3 = Vector3(0, 0, 0)
var locally_controlled: bool = false
var update_code: int
var controller_id: int
var moved: bool = false

var net_sync: Thread = Thread.new()

const SPEED: int = 700

onready var parent = get_parent()

func _ready():
    self.net_sync.start(self, "sync_position", null, 2)
    
    self.rotation = Vector3(0, 0.0001, 0)
    

func sync_position(_none):
    while true:
        if self.parent.ingame and self.moved:
            self.parent.update_position(self)
            self.moved = false
        OS.delay_msec(30)


func _physics_process(tdelta: float):
    if not is_on_floor():
        self.movement.y = -2
    else:
        self.movement.y = 0
        
    if self.locally_controlled:
        if is_on_floor():
            var rotated: bool = false
            
            if Input.is_action_pressed("LOCAL_LEFT"):
                rotate_tank(tdelta, 1)
                rotated = true
                moved = true
            elif Input.is_action_pressed("LOCAL_RIGHT"):
                rotate_tank(tdelta, -1)
                rotated = true
                moved = true
                
            if Input.is_action_pressed("LOCAL_FORWARD"):
                self.movement.x = 1
                moved = true
            elif Input.is_action_pressed("LOCAL_BACKWARD"):
                self.movement.x = -0.6
                moved = true
            else:
                self.movement.x = 0
    
            if rotated:
                self.movement.x *= 0.64
    
        var _collision = move_and_slide(tdelta * SPEED * self.movement.rotated(self.rotation.normalized(), self.rotation.length()), Vector3(0, 1, 0))
    
    else:
        var _collision = move_and_slide(tdelta * SPEED * movement, Vector3(0, 1, 0))
        

func rotate_tank(delta: float, direction: float):
    rotate_object_local(Vector3(0, 1, 0), delta * direction * PI * 0.65)

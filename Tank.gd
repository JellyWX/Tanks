extends KinematicBody

var movement: Vector3 = Vector3(0, 0, 0)
var locally_controlled: bool = false

const SPEED: int = 450

func _ready():
    self.rotation = Vector3(0, 0.0001, 0)

func _process(tdelta: float):
    if locally_controlled:
        if not is_on_floor():
            movement.y = -1
        else:
            movement.y = 0
        
            if Input.is_action_pressed("LOCAL_FORWARD"):
                movement.x = 1
            elif Input.is_action_pressed("LOCAL_BACKWARD"):
                movement.x = -0.6
            else:
                movement.x = 0
    
        var _collision = move_and_slide(tdelta * SPEED * movement.rotated(self.rotation.normalized(), self.rotation.length()), Vector3(0, 1, 0))
    
        if Input.is_action_pressed("LOCAL_LEFT"):
            rotate_tank(tdelta, 1)
        elif Input.is_action_pressed("LOCAL_RIGHT"):
            rotate_tank(tdelta, -1)

func rotate_tank(delta: float, direction: float):
    rotate_object_local(Vector3(0, 1, 0), delta * direction * PI * 0.5)
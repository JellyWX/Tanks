extends KinematicBody

var movement: Vector3 = Vector3(0, 0, 0)
var rotated: bool = false

const SPEED: int = 600

func _process(tdelta: float):
    movement.z = 0
    
    if not is_on_floor():
        movement.x = 0
        movement.y = -1
    else:
        movement.y = 0
    
        if Input.is_action_pressed("LOCAL_FORWARD"):
            movement.x = 1
        elif Input.is_action_pressed("LOCAL_BACKWARD"):
            movement.x = -1
        else:
            movement.x = 0

        if rotated:
            movement = movement.rotated(self.rotation.normalized(), self.rotation.length())

    move_and_slide(tdelta * SPEED * movement, Vector3(0, 1, 0))

    if Input.is_action_pressed("LOCAL_LEFT"):
        rotated = true
        rotate_tank(tdelta, 1)
    elif Input.is_action_pressed("LOCAL_RIGHT"):
        rotated = true
        rotate_tank(tdelta, -1)

func rotate_tank(delta: float, direction: float):
    rotate_object_local(Vector3(0, 1, 0), delta * direction * PI * 0.6)
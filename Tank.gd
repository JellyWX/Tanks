extends Spatial

var movement: Vector3 = Vector3(0, 0, 0)

func _process(tdelta: float):
    if Input.is_action_pressed("LOCAL_FORWARD"):
        movement.x = 1
    elif Input.is_action_pressed("LOCAL_BACKWARD"):
        movement.x = -1
    else:
        movement.x = 0   

    translate_object_local(tdelta * 6 * movement)

    if Input.is_action_pressed("LOCAL_LEFT"):
        rotate_tank(tdelta, 1)
    elif Input.is_action_pressed("LOCAL_RIGHT"):
        rotate_tank(tdelta, -1)

func rotate_tank(delta: float, direction: float):
    rotate_object_local(Vector3(0, 1, 0), delta * direction * PI * 0.6)
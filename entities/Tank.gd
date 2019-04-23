extends KinematicBody

var movement: Vector3 = Vector3(0, 0, 0)
var locally_controlled: bool = false
var update_code: int
var controller_id: int
var moved: bool = false

var net_sync: Thread = Thread.new()

const SPEED: int = 700
const TURN_SPEED: float = 0.68
const BACKWARD_MULTIPLIER: float = 0.6
const TURN_MULTIPLIER: float = 0.64
const FALL_MULTIPLIER: float = 2.0
const TICK_TIME: int = 30

onready var parent = get_parent()
onready var turret = get_node("Turret")
onready var body = get_node("Body")
onready var particles = get_node("Turret/Particles")

func _ready():
    # start the network syncing thread
    self.net_sync.start(self, "sync_position", null, 2)
    
    # set a rotation because otherwise things don't work
    get_node("Body").rotation = Vector3(0, 0.0001, 0)
    

func sync_position(_none):
    while true:
        # if ingame and the tank has moved
        if self.parent.ingame and self.moved:
            self.parent.update_position(self)
            self.moved = false
        # wait 30 ms
        OS.delay_msec(TICK_TIME)


func _physics_process(tdelta: float):
    get_node("CollisionShape").set_rotation(self.body.rotation)
    
    self.fall()
        
    if self.locally_controlled:
        self.rotate_turret()

        self.check_firing()

        if self.is_on_floor():
            self.check_movement_input(tdelta)
    
        var _collision = move_and_slide(tdelta * SPEED * self.movement.rotated(get_node("Body").rotation.normalized(), get_node("Body").rotation.length()), Vector3(0, 1, 0))
    
    else:
        var _collision = move_and_slide(tdelta * SPEED * movement, Vector3(0, 1, 0))

        
func fall():
    if not self.is_on_floor():
        self.movement.y = -1 * FALL_MULTIPLIER
    else:
        self.movement.y = 0


func check_firing():
    if Input.is_action_just_pressed("PRIMARY"):
        fire()
    else:
        self.particles.emitting = false
        

func send_fire_request():
    # restart the particles
    self.particles.emitting = true
    self.particles.restart()
    
    self.parent.update_firing(self)


func fire():
    pass


func check_movement_input(tdelta: float):
    var rotated: bool = false
    
    if Input.is_action_pressed("LOCAL_LEFT"):
        self.rotate_tank(tdelta, 1)
        rotated = true
        self.moved = true
    elif Input.is_action_pressed("LOCAL_RIGHT"):
        rotate_tank(tdelta, -1)
        rotated = true
        self.moved = true
        
    if Input.is_action_pressed("LOCAL_FORWARD"):
        self.movement.x = 1
        self.moved = true
    elif Input.is_action_pressed("LOCAL_BACKWARD"):
        self.movement.x = -1 * BACKWARD_MULTIPLIER
        self.moved = true
    else:
        self.movement.x = 0

    if rotated:
        self.movement.x *= TURN_MULTIPLIER


func rotate_turret():
    var camera: Camera = get_tree().get_root().get_camera()
        
    var tank_screen_pos: Vector2 = camera.unproject_position(self.translation)
    
    var cursor_pos: Vector2 = get_viewport().get_mouse_position()
    
    self.turret.rotation.y = -cursor_pos.angle_to_point(tank_screen_pos)


func rotate_tank(delta: float, direction: float):
    self.body.rotate_object_local(Vector3(0, 1, 0), delta * direction * PI * TURN_SPEED)

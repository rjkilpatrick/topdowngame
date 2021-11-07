extends KinematicBody

var velocity: Vector3 = Vector3()

const MAX_SPEED: float = 3.0

var bullet_scene: PackedScene = preload("res://bullet/Bullet.tscn")
var can_shoot: bool = true

var mouse_sensitivity = 0.002 # radians / pixel

var gravity_magnitude: float

onready var floor_cast = $FloorCast
onready var bullet_spawn = $RotationHelper/Character/BulletSpawn

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# TODO: Don't assume that gravity is always in the -y direction
	gravity_magnitude = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector").y

func shoot():
	if can_shoot:
		var bullet_instance = bullet_scene.instance()
#		bullet_instance.global_transform.origin = $Character/Body/Arm/Weapon.global_transform.origin
		bullet_instance.global_transform = bullet_spawn.global_transform
		
		# The bullets velocity does not currently vector sum the player's
		# veocity. This is not important at the moment, but if the player's
		# velocity becomes non-negligible, set the initial bullet velocity to it
		
		bullet_instance.set("BULLET_DAMAGE", 50.0)
		
		get_node("/root/").add_child(bullet_instance)

func _unhandled_input(event: InputEvent):
	# TODO: Handle joystick input
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$RotationHelper.rotate_y(-event.relative.x * mouse_sensitivity)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
	if event.is_action_pressed("player_fire"):
		shoot()
	if event is InputEventMouseButton and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false
	
	if event.is_action_pressed("player_jump") and floor_cast.is_colliding():
		velocity.y += 3.0

func _physics_process(delta: float):
	velocity.y += gravity_magnitude * delta
	
	var desired_direction = movement_strength()
	velocity.x = -desired_direction.y
	velocity.z = -desired_direction.x
	
	# TODO: Currently only moving relative to global space
	
	velocity = move_and_slide(velocity, Vector3.UP)


func movement_strength():
	var desired_direction = Vector2(
		Input.get_action_strength("player_forwards") - Input.get_action_strength("player_backwards"),
		Input.get_action_strength("player_left") - Input.get_action_strength("player_right")
	)
	
	desired_direction = desired_direction.normalized() * MAX_SPEED
	
	return desired_direction

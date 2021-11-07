extends KinematicBody

var health: float = 100.0

const MAX_SPEED: float = 2.0

onready var eye_line = $EyeLine
onready var update_target_timer = $UpdateTargetTimer
onready var navigation: Navigation = get_parent()
onready var target: Node = navigation.get_parent().get_node("Player")

const POINT_TOLERANCE = 0.5

var path: PoolVector3Array = []

func _ready():
	update_target_timer.connect("timeout", self, "update_path_to_target")

func take_damage(damage: float, _global_transform: Transform):
	health -= damage
	if health <= 0:
		self.visible = false
		queue_free()

func _physics_process(_delta: float):
	if can_see_target():
		pass
#	move_toward_target()

func can_see_target() -> bool:
	"""Returns true if target can be seen"""
	# Must be called from _physics_process
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(eye_line.global_transform.origin, target.global_transform.origin)
	
	return false

func move_toward_target():
	var displacement_to_target: Vector3 = target.transform.origin - self.global_transform.origin
	
	var relative_direction: Vector3 = Vector3.ZERO
	
	if not path.empty():
		relative_direction = path[0] - global_transform.origin
		if relative_direction.length() <= POINT_TOLERANCE:
			path.remove(0)
	else:
		relative_direction = target.transform.origin - global_transform.origin
	
	relative_direction.y = 0
	
	if displacement_to_target.length() > 1.0: # TODO: Add raycast
		move_and_slide(relative_direction.normalized() * MAX_SPEED, Vector3.UP)
		
	look_at_from_position(global_transform.origin, target.transform.origin, Vector3.UP)

func update_path_to_target():
	path = navigation.get_simple_path(global_transform.origin, target.transform.origin)


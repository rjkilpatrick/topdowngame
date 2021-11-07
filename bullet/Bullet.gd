extends Spatial

export var TIME_TO_LIVE = 1.0	# Units of seconds
export var SPEED = 10			# 1 space unit [metre] per second
export var BULLET_DAMAGE = 100	# Damage (arb. units)

var has_hit_something = false

func _ready():
	var timer = get_tree().create_timer(TIME_TO_LIVE)
	if timer.connect("timeout", self, "_on_timeout") != OK:
		print(self, "Timer did not connect")
	
	var area = get_node("Area")
	if area.connect("body_entered", self, "_on_collision") != OK:
		print(self, "Area did not connect")

func _on_timeout():
	queue_free()

func _physics_process(delta: float):
	var forward_dir = -self.transform.basis.z
	
	# TODO: Get gravity vector from PhysicsServer and accerlate downwards
	global_translate(forward_dir * SPEED * delta)

func _on_collision(body: Node):
	if not has_hit_something:
		if body.has_method("take_damage"):
			body.take_damage(BULLET_DAMAGE, self.global_transform)
	
	has_hit_something = true
	self.visible = false
	queue_free()

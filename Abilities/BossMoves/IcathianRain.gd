class_name IcathianRainAbility extends BaseTypeAbility

var player : Player
var deploy_speed = 50
var launch_speed = 250

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	abilityID = "IcathianRain"
	speed = deploy_speed
	dmg = 1
	timeout = 1
	lifetime = 6
	scale *= 1
	reaction_priority = 999
	element = "dark"
	myMovement = Movement.get_movement_object_by_name("bullet")
	$LifetimeTimer.wait_time = lifetime
	$LifetimeTimer.start()

func set_player(p : Player, origin : Vector2, rotate : float):
	player = p
	global_position = origin
	rotation = rotate

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	handle_movement(delta)

func _turn():
	var tween = create_tween()
	tween.tween_property(self, "rotation", global_position.angle_to_point(player.global_position), 0.5)
	#Can't figure out how to tween look at so yeah
	#look_at(player.global_position)
	tween.tween_property(self, "speed", launch_speed, 0.8).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "velocity", (player.global_position - global_position).normalized(), 1)
	$Line2D.started = true

func _on_body_entered(body: PhysicsBody2D):
	if body.is_in_group("players"):
		body.hit(dmg)
		queue_free()

func handle_reaction(spell: BaseTypeAbility):
	pass

func _on_turn_timer_timeout() -> void:
	_turn()

func _on_LifetimeTimer_timeout():
	queue_free()

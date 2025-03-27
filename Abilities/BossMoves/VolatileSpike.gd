class_name VolatileSpike extends BaseTypeAbility

@onready var Rain = preload("res://Abilities/BossMoves/IcathianRain.tscn")

var player : Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	abilityID = "VolatileSpike"
	reaction_priority = 999
	can_react = true
	speed = 50
	dmg = 50
	timeout = 1
	lifetime = 10
	element = "dark"
	$LifetimeTimer.wait_time = lifetime
	scale *= 4
	$LifetimeTimer.start()
	myMovement = Movement.get_movement_object_by_name("bullet")
	add_to_group("enemy_skills")
	add_to_group("skills")

func set_player(p : Player, pos : Vector2):
	player = p
	global_position = pos
	look_at(player.global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	handle_movement(delta)

func handle_reaction(reactant: BaseTypeAbility):
	print("MAKE IT RAIN")
	player.shake()
	for i in 9:
		var spike: IcathianRainAbility = Rain.instantiate()
		var rad = deg_to_rad(360/9 * i)
		var pos = Vector2(0,0)
		pos.x = global_position.x + cos(rad)
		pos.y = global_position.y + sin(rad)
		get_parent().get_parent().add_child(spike)
		spike.set_player(player, global_position, rad)
		spike.add_to_group("enemy_skills")
		spike.add_to_group("skills")
		spike.velocity = (pos - global_position).normalized()
	$AudioStreamPlayer2D.play()
	hide()
	set_collision_mask_value(1, false)
	set_collision_mask_value(3, false)
	await $AudioStreamPlayer2D.finished
	queue_free()

func _on_body_entered(body: PhysicsBody2D):
	print(body, "hit w spike")
	if body.is_in_group("players"):
		body.hit(dmg)

func _on_LifetimeTimer_timeout():
	queue_free()

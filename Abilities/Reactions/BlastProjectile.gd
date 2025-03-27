extends CharacterBody2D

var speed = 0
var dmg = 0
var center
var spell_caster

func _ready() -> void:
	# since i am a child of main, change process mode to pause
	self.process_mode = Node.PROCESS_MODE_PAUSABLE

func init(init_speed, init_dmg, init_center, caster):
	speed = init_speed
	dmg = init_dmg
	center = init_center
	spell_caster = caster

# called every frame
func _physics_process(delta: float):
	var collision = handle_movement(delta)
	self.scale += Vector2(0.05, 0.05)
	if collision:
		handle_collision(collision)

func _process(delta: float):
	# rotate self
	get_node("Sprite2D").rotation += 0.3

# Handles movement
func handle_movement(delta: float):
	return move_and_collide((self.global_position - center.global_position).normalized() * delta * speed)

# handles the collisions. Currently only enemy collisions matter
func handle_collision(collision: KinematicCollision2D):
	if collision and collision.get_collider().get_name() != "Player":
		if collision.get_collider().is_in_group("monsters"):
			collision.get_collider()._hit(dmg, "entropy", "sunder", spell_caster)
		despawn()

# despawn me
func despawn():
	queue_free()

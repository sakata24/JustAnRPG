extends KinematicBody2D

# is it mad
var aggro = false
# reference to chase the player
var player = KinematicBody2D
# how fast i move
var speed = 50
# my health
var health = 50
# exp i give
var bestowedXp = 1

signal giveXp(xp)

func _ready():
	pass

func init():
	pass

# handle internal processes
func _process(delta):
	if health <= 0:
		die()

# make the monster move
func _physics_process(delta):
	if aggro:
		chase(delta)

# chases the player
func chase(delta):
	if position.distance_to(player.position) > 1:
		move_and_slide(position.direction_to(player.position) * speed)

# hit by something
func _hit(dmg_to_take):
	health -= dmg_to_take
	print("i took ", dmg_to_take, " dmg")

# when player makes me mad
func _on_AggroRange_body_entered(body: KinematicBody2D):
	if body:
		if body.name == "Player":
			aggro = true
			player = body

# when i die
func die():
	emit_signal("giveXp", bestowedXp)
	queue_free()

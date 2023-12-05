extends CharacterBody2D

var abilityID = 0
var speed = 300
var dmg = 10
var timeout = 1.0
var lifetime = 1.0
var cooldown = 0.1
var element

# constructs the bullet
func init(skillDict):
	# set variables
	abilityID = skillDict["name"]
	speed = skillDict["speed"] * speed
	scale *= skillDict["size"]
	dmg *= skillDict["dmg"]
	timeout *= skillDict["timeout"]
	lifetime *= skillDict["lifetime"]
	element = skillDict["element"]
	if element == "sunder":
		$Texture.color = Color("#c00000")
	elif element == "entropy":
		$Texture.color = Color("#ffd966")
	elif element == "construct":
		$Texture.color = Color("#833c0c")
	elif element == "growth":
		$Texture.color = Color("#70ad47")
	elif element == "flow":
		$Texture.color = Color("#9bc2e6")
	elif element == "wither":
		$Texture.color = Color("#7030a0")
	add_to_group("skills")
	$LifetimeTimer.wait_time = lifetime
	# start timer
	$TimeoutTimer.wait_time = timeout
	$TimeoutTimer.start()
	# perform operation on spawn
	UniversalSkills.perform_spawn(self)

# handles movement of bullet
func _physics_process(delta):
	var collision = move_and_collide(get_velocity().normalized() * delta * speed)
	if collision and collision.get_collider().get_name() != "Player":
		if collision.get_collider().is_in_group("skills"):
			UniversalSkills.perform_reaction(self, collision.get_collider())
		if collision.get_collider().is_in_group("monsters"):
			collision.get_collider()._hit(dmg, $Texture.color)
		UniversalSkills.perform_despawn(self)

# if end of timeout, perform action (usually start lifetime timer)
func _on_TimeoutTimer_timeout():
	$LifetimeTimer.start()
	UniversalSkills.perform_timeout(self)

func _on_LifetimeTimer_timeout():
	UniversalSkills.perform_despawn(self)

func _delete():
	queue_free()

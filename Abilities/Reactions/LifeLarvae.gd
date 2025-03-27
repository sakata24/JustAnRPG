class_name LifeLarvae extends Area2D

var target: Enemy = null
var speed = 75
var dmg = 20
var spell_caster
var time = 0

func _ready():
	# find a target
	find_target()
	global_rotation = 0

func init(dmg: int, caster):
	self.dmg = int(dmg * 0.5)
	spell_caster = caster

func _physics_process(delta: float) -> void:
	# chase
	if target:
		chase_target(delta)
	else:
		find_target()

# chases a target using sin function to oscillate movement
func chase_target(delta: float):
	$NavigationAgent2D.target_position = target.global_position
	var move_target = $NavigationAgent2D.get_next_path_position()
	time += delta
	speed += sin(time * 6.5) * 4
	self.global_position += global_position.direction_to(move_target) * delta * speed

# find the nearest enemy
func find_target():
	for enemy: Enemy in get_tree().get_nodes_in_group("monsters"):
		# check for closest target in monsters
		if !target or self.global_position.distance_to(enemy.global_position) < self.global_position.distance_to(target.global_position):
			target = enemy

func _on_body_entered(body) -> void:
	if body.is_in_group("monsters"):
		body._hit(dmg, "growth", "entropy", spell_caster)
		queue_free()

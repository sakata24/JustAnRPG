class_name Monster extends Enemy

var upgradeDrop = preload("res://Interactables/UpgradeChest.tscn")

# am i mad
var aggro = false
# reference to chase the player
var player = CharacterBody2D
# damage
var my_dmg: int = 2
# base dmg for ref
var baseDmg = 2
# exp i give
var bestowedXp = 1
# am i attacking
var attacking = false
# can i move
var can_move = true
# can i drop upgrades
var droppable = true
# where i want to move
var move_target
# range at which i attack
var attack_range = 29
# how long to show indicator before attacking
var attack_timer_time = 0.9

signal give_xp(xp: int, elements: Array[String])

func _ready():
	speed = 100
	baseSpeed = 50
	health = 100
	maxHealth = 100
	add_to_group("monsters")

func init():
	pass

# handle internal processes
func _process(delta):
	if !can_move:
		$StatusLabel.visible = true
	else:
		$StatusLabel.visible = false
	if health <= 0:
		die()

# make the monster move
func _physics_process(delta):
	# set move target
	move_target = $NavigationAgent2D.get_next_path_position()
	move_and_slide()

# hit by something
func _hit(damage: DamageObject):
	super(damage)
	# aggro on the caster
	if damage.has_source() and damage.get_source() is Player:
		aggro = true
		player = damage.get_source()
		$PathTimer.start()

# when player makes me mad
func _on_AggroRange_body_entered(body: CharacterBody2D):
	if body:
		if body.name == "Player":
			aggro = true
			player = body
			$StateMachine/Chase.chase_target = body
			$StateMachine/Attacking.chase_target = body
			$PathTimer.start()

# when i die
func die():
	if droppable:
		var drop
		match randi_range(0, 2):
			0: 
				drop = upgradeDrop.instantiate()
			_:
				drop = null
		if drop != null:
			drop.position = position
			get_parent().add_child(drop)
	# give the player xp
	give_xp.emit(bestowedXp, lastElementsHitBy)
	print("bestowing")
	queue_free()

func _on_path_timer_timeout():
	$NavigationAgent2D.target_position = player.global_position

class_name DarkMageIcathianRainState extends State

@onready var Spike = load("res://Abilities/BossMoves/VolatileSpike.tscn")
@onready var Cannon = load("res://Abilities/BossMoves/Cannon.tscn")

@export var dark_mage: DarkMage 
@export var SPIKE_TIMER : float = 2.0 ## The time in between the firing of spikes
@export var CANNON_TIMER : float = 0.4 ## The time in between the firing of spikes
@export var CANNON_AMOUNT : int = 5 ## The amount of cannon spawns per attack

func enter():
	# Turn off invincibility
	dark_mage.invincible = false
	dark_mage.emit_signal("health_changed", dark_mage.health, false) # In the UI
	
	# set anim
	dark_mage.get_node("AnimatedSprite2D").set_animation("cast_orb")
	
	# Create new timer for spikes
	var spike_timer = Timer.new()
	spike_timer.wait_time = SPIKE_TIMER
	add_child(spike_timer)
	spike_timer.name = "attack_timer"
	
	# Create new timer for cannon
	var cannon_timer = Timer.new()
	cannon_timer.wait_time = CANNON_TIMER
	add_child(cannon_timer)
	cannon_timer.name = "attack_timer"
	
	# Connect timers
	spike_timer.connect("timeout", _on_spike_timer_timeout)
	cannon_timer.connect("timeout", _on_cannon_timer_timeout)
	
	#Start timers
	spike_timer.start()
	if dark_mage.invincible_stage > 1:
		cannon_timer.start()

func exit():
	get_node("attack_timer").queue_free()
	dark_mage.invincible_stage += 1

func _on_spike_timer_timeout():
	# load the projectile
	var projectile: BaseTypeAbility = Spike.instantiate()
	# spawn the projectile and initialize it
	projectile.set_player(dark_mage.player, dark_mage.spell_cast_location.global_position)
	get_parent().add_child(projectile)
	# calculates the projectiles direction
	projectile.velocity = (dark_mage.player.global_position - projectile.position).normalized()

func _on_cannon_timer_timeout():
	for n in CANNON_AMOUNT:
		var inst = Cannon.instantiate()
		var pos : Vector2i
		pos.x = randi_range(dark_mage.player.global_position.x - dark_mage.CANNON_SPAWN_RADIUS, dark_mage.player.global_position.x + dark_mage.CANNON_SPAWN_RADIUS)
		pos.y = randi_range(dark_mage.player.global_position.y - dark_mage.CANNON_SPAWN_RADIUS, dark_mage.player.global_position.y + dark_mage.CANNON_SPAWN_RADIUS)
		inst.global_position = pos
		get_parent().add_child(inst)

func go_invincible():
	Transitioned.emit(self, "Invincible")
	dark_mage.invincible_stage += 1

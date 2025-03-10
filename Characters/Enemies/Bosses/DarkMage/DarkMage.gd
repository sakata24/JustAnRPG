extends Monster

@onready var Minion = load("res://Characters/Enemies/Monster/Monster.tscn")

@export var CANNON_SPAWN_RADIUS : int = 100
@export var CRYSTAL_AMOUNT_PER_STAGE : Array = [4, 5]

var invincible_stage = 0
var invincible := true
var current_crystal_amount : int
var playable_area : Rect2

signal health_changed

func _ready():
	# can i drop upgrades
	droppable = false
	health = 500
	maxHealth = 500
	add_to_group("monsters")
	await call_deferred("_set_player")
	$StateMachine/Idle._go_invincible()

# override so i dont move
func _physics_process(delta: float) -> void:
	pass

func _set_player():
	player = get_parent().get_parent().get_parent().get_node("Player")
	_connect_to_HUD()

func _connect_to_HUD():
	var HUD = player.get_parent().get_node("HUD")
	connect("health_changed", HUD._on_boss_health_change)
	HUD.show_boss_bar("Dark Mage", health)
	emit_signal("health_changed", maxHealth, true)


# hit by something
func _hit(dmg_to_take, dmg_type_1, dmg_type_2, caster):
	if invincible:
		# Spawn "Immune" damage number
		var dmgNum = damageNumber.instantiate()
		dmgNum.set_colors(AbilityColor.get_color_by_string(dmg_type_1), AbilityColor.get_color_by_string(dmg_type_2))
		get_parent().add_child(dmgNum)
		dmgNum.set_value_and_pos("Immune", self.global_position)
		# Update UI
		emit_signal("health_changed", health, true)
	else: #Hitting the half health threshold
		if (invincible_stage == 0 && health-dmg_to_take <= maxHealth/2):
			super(dmg_to_take, dmg_type_1, dmg_type_2, caster)
			$StateMachine/Attack.go_invincible()
		else:
			super(dmg_to_take, dmg_type_1, dmg_type_2, caster)
			emit_signal("health_changed", health, false)


# when i die
func die():
	emit_signal("give_xp", bestowedXp)
	var drop
	match randi_range(0, 2):
		0: 
			drop = upgradeDrop.instantiate()
		_:
			drop = null
	if drop != null:
		drop.position = position
		get_parent().add_child(drop)
	queue_free()


func surround_player_with_minions():
	var player_pos = player.global_position
		#Spawn Minions around the player
	for i in (5):
		var rad = deg_to_rad(360/(5) * i - 45)
		var inst: Enemy = Minion.instantiate()
		inst.droppable = false
		inst.global_position.x = player_pos.x + cos(rad) * 50
		inst.global_position.y = player_pos.y + sin(rad) * 50
		get_parent().call_deferred("add_child", inst)

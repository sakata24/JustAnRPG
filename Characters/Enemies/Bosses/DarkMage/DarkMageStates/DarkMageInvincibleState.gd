class_name DarkMageInvincibleState extends State

@onready var Crystal = load("res://Characters/Enemies/Bosses/DarkMage/BarrierCrystal.tscn")

@export var dark_mage: DarkMage

var current_crystal_amount : int

func enter():
	# Turn on invincibility
	dark_mage.invincible = true
	dark_mage.emit_signal("health_changed", dark_mage.health, true)
	dark_mage.get_node("AnimatedSprite2D").set_animation("cast_staff")
	spawn_crystals()
	current_crystal_amount = dark_mage.CRYSTAL_AMOUNT_PER_STAGE[dark_mage.invincible_stage]

#Spawns barrier crystals for Invincible states
func spawn_crystals():
	for i in dark_mage.CRYSTAL_AMOUNT_PER_STAGE[dark_mage.invincible_stage]:
		# Get location to put crystals
		var rad = deg_to_rad(360/dark_mage.CRYSTAL_AMOUNT_PER_STAGE[dark_mage.invincible_stage] * i - 90)
		var inst = Crystal.instantiate()
		inst.global_position.x = dark_mage.global_position.x + cos(rad) * 150
		inst.global_position.y = dark_mage.global_position.y + sin(rad) * 150
		# Spawn crystals
		dark_mage.get_parent().call_deferred("add_child", inst)
		inst.connect("destroyed_crystal", _on_crystal_destroyed)
		inst.add_to_group("monsters")

func _on_crystal_destroyed():
	current_crystal_amount -= 1
	if current_crystal_amount == 0: #When the last crystal is destroyed
		Transitioned.emit(self, "Attack")
	else:
		dark_mage.surround_player_with_minions()

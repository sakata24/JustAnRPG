class_name Player extends CharacterBody2D

var dashScene = load("res://Abilities/Dash.tscn")

var remaining_casts = 0
var ability_ref: String = ""

var damageNumber = preload("res://HUDs/DamageNumber.tscn")

@onready var focus = $ProjectilePivot/ProjectileSpawnPos
@onready var my_cam: PlayerCamera = get_node("Camera2D")

signal moving_to()
signal dashing_()
signal cooling_down(skill_cds, skill_cds_max)
signal cooling_dash(dash_cd, dash_cd_max)
signal player_hit(newHP, maxHP)

# instance variables for player HP
var health = 25
var max_health = 25

# instance variables for player movement
var max_speed = 150
var speed = 0
var moving = false
var dashing = false
var move_dir
var move_target = Vector2()
var movement = Vector2()
var cast_target = Vector2()

# to be changed when the player obtains a new skill
var upgradesChosen = []

# to be changed when the player equips different skills
var equippedSkills = ["bolt", "charge", "rock", "fountain"]

var skillReady = [true, true, true, true]
# the amt of physics processes to occur before ability to use the skill again
var skillCD = [0, 0, 0, 0]
# the current amt of physics processes that ran since last using the skill
var skillTimer = [10, 10, 10, 10]
# can dash
var canDash = true
# the dash ready
var dashIFrames = 0
# can cast an ability
var canCast = true
# is casting
var casting = false
# current run data every run reinstantiated
@onready var current_run_data: PlayerRunData = PlayerRunData.new()

# on ready
func _ready():
	# Update the equipped skills
	equippedSkills = PersistentData.get_equipped_skills()
	# Make the player look right
	move_target = Vector2(self.position.x, 10000.0)
	self.add_to_group("players")
	init_skill_cooldowns()
	
func init_skill_cooldowns():
	# set the cooldowns
	skillCD[0] = SkillDataHandler.skill_dict[equippedSkills[0]]["cooldown"] * 10
	skillCD[1] = SkillDataHandler.skill_dict[equippedSkills[1]]["cooldown"] * 10
	skillCD[2] = SkillDataHandler.skill_dict[equippedSkills[2]]["cooldown"] * 10
	skillCD[3] = SkillDataHandler.skill_dict[equippedSkills[3]]["cooldown"] * 10
	# set the timers that count the cooldown
	skillTimer[0] = skillCD[0]
	skillTimer[1] = skillCD[1]
	skillTimer[2] = skillCD[2]
	skillTimer[3] = skillCD[3]

func get_unlocked_skills():
	return PersistentData.get_unlocked_skills()

func get_equipped_skills():
	return equippedSkills

func _physics_process(delta):
	$ProjectilePivot.look_at(cast_target)
	emit_signal("cooling_down", skillTimer, skillCD)
	emit_signal("cooling_dash", $DashTimer.time_left, $DashTimer.wait_time)
	check_and_set_skill_timers()

func check_and_set_skill_timers():
	if skillTimer[0] >= skillCD[0]:
		skillReady[0] = true
	else:
		skillTimer[0] += 1
		
	if skillTimer[1] >= skillCD[1]:
		skillReady[1] = true
	else:
		skillTimer[1] += 1
		
	if skillTimer[2] >= skillCD[2]:
		skillReady[2] = true
	else:
		skillTimer[2] += 1
		
	if skillTimer[3] >= skillCD[3]:
		skillReady[3] = true
	else:
		skillTimer[3] += 1

func choose_sprite_direction():
	if movement.x < 0:
		$AnimatedSprite2D.flip_h = true
		$Shadow.scale.x = -1
	elif movement.x > 0:
		$AnimatedSprite2D.flip_h = false
		$Shadow.scale.x = 1

# This function handles skill casting
func cast_ability(slot_num: int) -> bool:
	# check if ready
	if (not skillReady[slot_num]) or (not $CastTimer.is_stopped()):
		return false
	# casting
	casting = true
	# start cooldowns
	skillReady[slot_num] = false
	skillTimer[slot_num] = 0
	# obtain reference to the ability dict
	var ability_name: String = equippedSkills[slot_num]
	# cannot cast for a short period
	canCast = false
	# get cast target
	cast_target = get_global_mouse_position()
	# stop moving
	speed = 0
	moving = false
	# start a timer
	$CastTimer.start()
	await $CastTimer.timeout
	canCast = true
	spawn_ability(ability_name)
	return true

func spawn_ability(ability_name: String):
	canCast = true
	var instantiated_ability: BaseTypeAbility = SkillSceneHandler.get_scene_by_name(ability_name)
	# spawn the projectile and initialize it
	get_parent().add_child(instantiated_ability)
	# init after creation
	instantiated_ability.init(SkillDataHandler._get_ability(ability_name), cast_target, self)
	# apply player's run buffs after creation
	apply_run_buffs(instantiated_ability)

# applys the player's run buffs
func apply_run_buffs(ability: BaseTypeAbility):
	# numbers can be handled by the spell
	current_run_data.apply_run_buffs(ability)
	# player handles multicast
	if ability.element == "sunder" and current_run_data.sunder_extra_casts > 0:
		remaining_casts = current_run_data.sunder_extra_casts 
		ability_ref = ability.abilityID
		$MultiCastTimer.start()

func _on_multi_cast_timer_timeout():
	if remaining_casts > 0 and ability_ref:
		spawn_ability(ability_ref)
		remaining_casts -= 1
		$MultiCastTimer.start()
	else:
		remaining_casts = 0
		ability_ref =""

func gain_xp(amount: int, elements: Array[String]):
	print("gaining xp")
	for element in elements:
		PersistentData.increase_xp(amount, element)

func hit(damage):
	health -= damage
	emit_signal("player_hit", health, max_health)
	var dmgNum = damageNumber.instantiate()
	dmgNum.modulate = Color(255, 0, 0)
	get_parent().add_child(dmgNum)
	dmgNum.set_value_and_pos(damage, self.global_position)

func upgrade(upgrade_int):
	match upgrade_int:
		0: current_run_data.sunder_dmg_boost += 0.1
		1: current_run_data.sunder_extra_casts += 1
		2: current_run_data.entropy_speed_boost += 0.1
		3: current_run_data.entropy_crit_chance += 0.15
		4: current_run_data.construct_size_boost += 0.1
		5: current_run_data.construct_ignore_walls = true
		6: current_run_data.growth_lifetime_boost += 0.1
		7: current_run_data.growth_reaction_potency += 0.1
		8: 
			current_run_data.flow_cooldown_reduction *= 0.9
			for i in range(0, 4):
				if SkillDataHandler.skill_dict[equippedSkills[i]]["element"] == "flow":
					skillCD[i] *= current_run_data.flow_cooldown_reduction
					skillTimer[i] = skillCD[i]
		9: current_run_data.flow_size_boost += 0.1
		10: current_run_data.wither_lifetime_boost += 0.1
		11: current_run_data.wither_size_boost += 0.1
		_: pass
	print("upgraded: ", upgrade_int)

func spawn_light():
	var light = $PointLight2D
	light.scale = Vector2(20,20)
	light.visible = true
	var tween = create_tween()
	tween.tween_property(light, "scale", Vector2(1.5,1.5), 2)
	await tween.finished
	return true

func shake():
	my_cam.apply_shake()

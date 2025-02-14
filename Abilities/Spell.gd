class_name Spell extends Area2D

var abilityID = 0
var speed = 300
var velocity = Vector2.ZERO
var dmg = 10
var timeout = 1
var lifetime = 1
var cooldown = 0.1
var size = 1
var reaction_priority = 0
var element
var can_react
var spell_caster

const CAST_RANGE = 500

# constructs the bullet
func init(skill_dict, cast_target, caster):
	# set variables
	abilityID = skill_dict["name"]
	element = skill_dict["element"]
	size *= skill_dict["size"]
	dmg *= skill_dict["dmg"]
	lifetime *= skill_dict["lifetime"]
	reaction_priority = skill_dict["priority"]
	spell_caster = caster
	setup_spell(cast_target)
	# perform operation on spawn
	SkillDataHandler.perform_spawn(self, cast_target, caster)

func setup_spell(cast_target: Vector2):
	add_to_group("skills")
	self.position = cast_target

func _on_SpellBody_body_entered(body):
	if body.name != "Player":
		if body.is_in_group("skills"):
			handle_reaction(body)
		if body.is_in_group("monsters"):
			handle_enemy_interaction(body)

# Handles reaction data. MUST BE OVERWRITTEN OR THE SPELL DOES NO REACTION
func handle_reaction(reactant: Node2D):
	# Disable own collision with other spells to not react.
	set_collision_layer_value(3, false)
	set_collision_mask_value(3, false)

# Handles collision when enemy is hit. Spells do not typically despawn.
func handle_enemy_interaction(enemy: Node2D):
	enemy._hit(self.dmg, self.element, self.element, self.spell_caster)

# Handles reaction interactions with other spells
func _on_area_entered(area):
	if area.is_in_group("skills"):
		handle_reaction(area)

func _on_LifetimeTimer_timeout():
	despawn()

func despawn():
	self.queue_free()

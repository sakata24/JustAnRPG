# Class responsible for handling reactions of a "type"
# Meant to act as a parent for <type>Ability.gd

class_name BaseTypeAbility extends Area2D

var myMovement: Movement
var mySpawnBehavior: SpawnBehavior
var myModifiers = []

var abilityID = ""
var speed = 300
var velocity = Vector2.ZERO
var dmg: int = 10
var timeout = 1
var lifetime = 1
var cooldown = 0.1
var reaction_priority = 0
var element
var can_react
var spell_caster

const CAST_RANGE = 500

# constructs the bullet
func init(skill_dict: Dictionary, cast_target: Vector2, caster: CharacterBody2D):
	# set variables
	abilityID = skill_dict["name"]
	element = skill_dict["element"]
	dmg *= skill_dict["dmg"]
	speed *= skill_dict["speed"]
	lifetime *= skill_dict["lifetime"]
	reaction_priority = skill_dict["priority"]
	spell_caster = caster
	myMovement = Movement.get_movement_object_by_name(skill_dict["movement"])
	mySpawnBehavior = SpawnBehavior.get_spawn_behavior_object_by_name(skill_dict["spawn"])
	setup_spell(cast_target, caster)
	for modifier: Modifier in myModifiers:
		modifier.apply(self)

# set up the spell
func setup_spell(cast_target: Vector2, caster: Node2D):
	add_to_group("skills")
	$LifetimeTimer.wait_time *= lifetime
	$LifetimeTimer.start()
	mySpawnBehavior.apply(self, cast_target)

# run every frame
func _physics_process(delta):
	handle_movement(delta)

# handles movement of bullet. Standard is a constant speed in a straight line.
func handle_movement(delta):
	myMovement.apply_movement(self, delta)

# on collision
func _on_body_entered(body: PhysicsBody2D):
	if body.name != "Player":
		if body.is_in_group("monsters"):
			handle_enemy_interaction(body)
		else:
			handle_other_interaction(body)

# Handles reaction data. MUST BE OVERWRITTEN OR THE SPELL DOES NO REACTION
func handle_reaction(reactant: BaseTypeAbility):
	# Disable own collision with other spells to not react.
	pass

# returns true if my priority is higher
func is_reaction_owner(other: BaseTypeAbility) -> bool:
	var my_reaction_priority = self.reaction_priority
	var other_reaction_priority = other.reaction_priority
	# case where priority is equal, determine based on type
	if self.reaction_priority == other.reaction_priority:
		my_reaction_priority = self.get_new_reaction_priority_from_elements()
		other_reaction_priority = other.get_new_reaction_priority_from_elements()
	# higher priority means the reaction sticks to it more often
	if my_reaction_priority > other_reaction_priority:
		return true
	else: 
		return false

# idkkk
func get_new_reaction_priority_from_elements() -> int:
	match self.element:
		"sunder": return (self.reaction_priority * 10) + 2
		"entropy": return (self.reaction_priority * 10) - 1
		"construct": return (self.reaction_priority * 10) + 5
		"growth": return (self.reaction_priority * 10)
		"flow": return (self.reaction_priority * 10) - 2
		"wither": return (self.reaction_priority * 10) + 1
		_: return 0

# Handles collision when enemy is hit. Spells do not typically despawn.
func handle_enemy_interaction(enemy: Enemy):
	enemy._hit(self.dmg, self.element, self.element, self.spell_caster)

# handles other things like walls
func handle_other_interaction(thing: Node2D):
	pass

# Handles reaction interactions with other spells
func _on_area_entered(area: Area2D):
	if area.is_in_group("skills"):
		# make sure spells cant interact twice
		remove_interactability()
		# make sure only one spell handles it
		if area.is_in_group("skills") and self.is_reaction_owner(area):
			call_deferred("handle_reaction", area)
		else:
			return

# makes self un interactable after collision
func remove_interactability():
	set_collision_layer_value(3, false)
	set_collision_mask_value(3, false)
	
func _on_lifetime_timer_timeout() -> void:
	despawn()

func despawn():
	self.queue_free()

# Creates a new reaction.
func create_new_reaction(other: Node2D):
	if other:
		var reaction_scene = get_reaction_scene(other.element)
		if reaction_scene:
			# set as the child
			self.add_child(reaction_scene)
			# after entering tree things and if need info from both spells reacting
			reaction_scene.init({"source": self, "reactant": other})

# FUNCTION TO BE OVERLOADED
func get_reaction_scene(reactant_element: String) -> Node2D:
	print("reaction not implemented!")
	return null

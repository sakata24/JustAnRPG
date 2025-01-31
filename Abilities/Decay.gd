class_name DecayBullet extends Bullet

# grab the ability functions on load
@onready var WitherAbility = preload("res://Abilities/BaseAbilityScripts/WitherAbility.gd").new()

# Initial creation of object on load.
func init(skill_dict: Dictionary, cast_target: Vector2, caster: Node2D):
	$AnimatedSprite2D.set_sprite_frames(CustomResourceLoader.decaySpriteRes)
	super.init(skill_dict, cast_target, caster)

# Handles the reaction effects.
func handle_reaction(reactant: Node2D):
	super(reactant)
	WitherAbility.create_new_reaction(self, reactant)

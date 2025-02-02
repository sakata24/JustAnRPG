# This script is a patchwork method of multiple inheritance.
# Some reactions are NOT Area2Ds, and some are. This allows the reaction that inherits from Area2D to inherit from this class and still inherit from the Reaction class.

class_name AreaReaction extends Area2D

@onready var ReactionScript = preload("res://Abilities/Reactions/BaseReactions/Reaction.gd").new()

func init(reaction_components: Dictionary):
	ReactionScript.init(reaction_components)

func spawn_reaction_name(name: String, origin_spell: Node2D, dmg_color_1: Color, dmg_color_2: Color):
	ReactionScript.spawn_reaction_name(name, origin_spell, dmg_color_1, dmg_color_2)

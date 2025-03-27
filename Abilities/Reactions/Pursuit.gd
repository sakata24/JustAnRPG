# Pursuit:
# Creation: flow + growth
# cause any bullets to target enemies and increase their damage

class_name PursuitReaction extends Reaction

func init(reaction_components: Dictionary):
	spawn_reaction_name("pursuit!", reaction_components["source"], Color("#663c33"), Color("#36c72c"))
	reaction_components["source"].myMovement = Movement.get_movement_object_by_name("homing")
	# check that it doesnt already have a pursuit node if not, make it
	if !reaction_components["reactant"].has_node("Pursuit"):
		reaction_components["reactant"].add_child(SkillSceneHandler.get_scene_by_name("pursuit"))
		reaction_components["reactant"].myMovement = Movement.get_movement_object_by_name("homing")
	apply_buff_to_spell(reaction_components["reactant"])
	apply_buff_to_spell(reaction_components["source"])

func apply_buff_to_spell(spell: BaseTypeAbility):
	# validate it is homing, then auto assign a target and increase its dmg
	if spell.myMovement is HomingMovement and spell.speed > 0:
		spell.myMovement.find_target(spell, get_tree())
		spell.dmg += spell.dmg
		spell.get_node("LifetimeTimer").start()

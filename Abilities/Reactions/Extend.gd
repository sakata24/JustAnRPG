# Extend:
# Creation: growth + wither
# increase the lifetime of the spells and restart their timers

class_name ExtendReaction extends Reaction

func init(reaction_components: Dictionary):
	extend_timers(reaction_components)
	spawn_reaction_name("extend!", get_parent(), Color("#36c72c"), Color("#591b82"))

func extend_timers(reaction_components: Dictionary):
	reaction_components["source"].get_node("LifetimeTimer").wait_time *= 1.5
	reaction_components["source"].get_node("LifetimeTimer").start()
	reaction_components["reactant"].get_node("LifetimeTimer").wait_time *= 1.5
	reaction_components["reactant"].get_node("LifetimeTimer").start()

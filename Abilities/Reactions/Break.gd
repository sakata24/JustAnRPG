# Break:
# Creation: sunder + flow
# increase the size of the flow spell every tick of the timer

class_name BreakReaction extends Reaction

func init(reaction_components: Dictionary):
	# reparent myself if this node is NOT on the flow node.
	if reaction_components["source"].element != "flow":
		reparent(reaction_components["reactant"], false)
	# spawn reaction name
	spawn_reaction_name("break!", get_parent(), Color("#7a0002"), Color("#82b1ff"))

# make my parent grow in size
func _on_tick_timer_timeout() -> void:
	get_parent().scale += Vector2(0.1, 0.1)

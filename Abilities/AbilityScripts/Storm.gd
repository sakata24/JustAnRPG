class_name StormAbility extends EntropyAbility

func init(skill_dict: Dictionary, cast_target: Vector2, caster: Node2D):
	super.init(skill_dict, cast_target, caster)

# Handles the reaction effects.
func handle_reaction(reactant: Node2D):
	super(reactant)
	create_new_reaction(reactant)

# damage enemies in radius
func _on_timeout_timer_timeout():
	# Tick dmg every 0.5 initially, depending on amt of bodies in circle tick differently
	if self.has_overlapping_bodies():
		var array = []
		for body in self.get_overlapping_bodies():
			if body.is_in_group("monsters"):
				array.push_back(body)
		if not array.is_empty():
			var enemy = array[randi() % array.size()]
			handle_enemy_interaction(enemy)
			$TimeoutTimer.wait_time = (0.9/(array.size()+1))
	# Only start after changing wait time
	$TimeoutTimer.start()

# ignore things entering this Ability
func _on_SpellBody_body_entered(body):
	if body.is_in_group("skills"):
		handle_reaction(body)
	else:
		pass

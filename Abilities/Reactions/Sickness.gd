# Sickness:
# Creation: entropy + wither
# create a field that applies a random debuff to enemies in the radius

class_name SicknessReaction extends AreaReaction

var debuffedEnemies

# called after creation and add_child
func init(reaction_components: Dictionary):
	spawn_reaction_name("sickness!", get_parent(), Color("#ffd966"), Color("#591b82"))

# every tick add debuff
func _on_tick_timer_timeout():
	if has_overlapping_bodies():
		remove_debuffs_from_debuffed_enemies()
		debuff_enemies_in_radius()

# when this effect is done, cleanse
func _on_lifetime_timer_timeout():
	remove_debuffs_from_debuffed_enemies()
	queue_free()

# cleanse
func remove_debuffs_from_debuffed_enemies():
	if debuffedEnemies != null:
		for body in debuffedEnemies:
			if body != null and body.is_in_group("monsters"):
				body.can_move = true
				body.speed = body.baseSpeed
				body.myDmg = body.baseDmg

# apply random debuff
func debuff_enemies_in_radius():
	debuffedEnemies = get_overlapping_bodies()
	for body: Monster in debuffedEnemies:
		if body.is_in_group("monsters"):
			var rand = randi_range(0, 2)
			if rand == 0:
				body.can_move = false
				body.velocity
			elif rand == 1:
				body.speed *= 0.5
			elif rand == 2:
				body.myDmg *= 0.5

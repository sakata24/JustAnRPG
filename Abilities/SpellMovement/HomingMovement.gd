class_name HomingMovement extends Movement

# must assign target to this movement for it to actually track
var target: Node2D = null

# moves the spell towards target
func apply_movement(spell: BaseTypeAbility, delta: float):
	if target and spell.speed >= 0:
		spell.look_at(target.global_position)
		spell.global_position += spell.global_position.direction_to(target.global_position) * delta * spell.speed

# manually set a target
func set_target(new_target: Node2D):
	target = new_target

# needs a reference to the tree to search the group
func find_target(movement_owner, tree_ref):
	for enemy: Enemy in tree_ref.get_nodes_in_group("monsters"):
		# check for closest target in monsters
		if !target or movement_owner.global_position.distance_to(enemy.global_position) < movement_owner.global_position.distance_to(target.global_position):
			set_target(enemy)

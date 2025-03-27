class_name FissureAbility extends ConstructAbility

var CLAMP_DISTANCE = 58 

func init(skill_dict, cast_target, caster):
	super(skill_dict, cast_target, caster)
	set_angle_and_position(cast_target, caster.global_position)

# sets the angle and position of the spell
func set_angle_and_position(cast_target: Vector2, caster_position: Vector2):
	var offset = (cast_target - caster_position).normalized() * CLAMP_DISTANCE
	self.position = caster_position + offset
	self.look_at(cast_target)

# Handles the reaction effects.
func handle_reaction(reactant: Node2D):
	super(reactant)
	create_new_reaction(reactant)

# tick timer timeout = 
func _on_tick_timer_timeout() -> void:
	self.set_collision_mask_value(2, !get_collision_mask_value(2))
	$TickTimer.start()

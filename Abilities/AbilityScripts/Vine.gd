class_name VineSpell extends GrowthAbility

var CLAMP_DISTANCE = 108

func init(skill_dict, cast_target, caster):
	super(skill_dict, cast_target, caster)
	set_angle_and_position(cast_target, caster.global_position)

# sets the angle and position of the spell
func set_angle_and_position(cast_target: Vector2, caster_position: Vector2):
	var offset = (cast_target - caster_position).normalized() * CLAMP_DISTANCE
	self.position = caster_position + offset
	self.look_at(caster_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	set_angle_and_position(get_global_mouse_position(), self.spell_caster.global_position)

# Handles the reaction effects.
func handle_reaction(reactant: Node2D):
	super(reactant)
	create_new_reaction(reactant)

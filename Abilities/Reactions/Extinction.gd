# Extinction:
# Creation: construct + wither
# execute enemies that fall below a specific hp in a radius around the source

class_name ExtinctionReaction extends AreaReaction

const BASE_EXTINCTION_RADIUS = 32

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(reaction_components: Dictionary):
	spawn_reaction_name("extinction!", get_parent(), Color("#663c33"), Color("#591b82"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("monsters") and ((body.health * 10) <= (body.maxHealth) and body.health > 0):
			body._hit(999, "construct", "wither", get_parent().spell_caster)

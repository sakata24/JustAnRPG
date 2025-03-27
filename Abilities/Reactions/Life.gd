# Life:
# Creation: growth + entropy
# spawn 4 larvae that chase the nearest target

class_name LifeReaction extends Reaction

var parents
var dmg

# call after entering scene tree
func init(reaction_components: Dictionary):
	parents = reaction_components
	# reparent myself to main to not despawn when parents react and destroy themselves
	reparent(parents["source"].get_parent(), true)
	dmg = parents["source"].dmg + parents["reactant"].dmg
	# spawn reaction name
	spawn_reaction_name("life!", self, AbilityColor.GROWTH, AbilityColor.ENTROPY)
	for child: LifeLarvae in $LifeLarvaeList.get_children():
		child.init(dmg, parents["source"].spell_caster)

func _on_lifetime_timer_timeout() -> void:
	queue_free()

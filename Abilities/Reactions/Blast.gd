# Blast:
# Creation: sunder + entropy
# spawns projectiles that will explode from the source of the reaction

class_name BlastReaction extends Reaction

var dmg
var parents = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	self.scale = self.scale/get_parent().scale

# call after entering scene tree
func init(reaction_components: Dictionary):
	parents = reaction_components
	# reparent myself to main to not despawn when parents react and destroy themselves
	reparent(parents["source"].get_parent(), true)
	dmg = parents["source"].dmg + parents["reactant"].dmg
	# set projectiles dmg
	init_projectiles(parents["source"].spell_caster)
	# spawn reaction name
	spawn_reaction_name("blast!", self, Color("#7a0002"), Color("#7a0002"))
	# destroy my parents after getting all their data
	destroy_parents()

# initializes all blast projectiles
func init_projectiles(source: Node2D):
	for n in range(1, 9):
		get_node(str("Projectile", n)).init(450, dmg, self, source)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# despawn
func _on_timer_timeout():
	queue_free()

func destroy_parents():
	parents["source"].despawn()
	parents["reactant"].despawn()

# Shatter:
# Creation: sunder + construct
# create a pulsing field that detonates around the source 3 times

class_name ShatterReaction extends AreaReaction

var my_parent
var dmg = 0
var max_size = Vector2(2, 2)
var BASE_SHATTER_RADIUS = 32

# Called when the node enters the scene tree for the first time.
func init(reaction_components: Dictionary):
	my_parent = reaction_components["source"]
	dmg = my_parent.dmg
	spawn_reaction_name("shatter!", reaction_components["reactant"], Color("#663c33"), Color("#7a0002"))

func set_shatter_size():
	# loop thru parent collision polygon vectors and use the furthest to calculate discharge radius
	$CollisionShape2D.shape.radius = get_parent_bounding_radius() + BASE_SHATTER_RADIUS

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	modulate_alpha_down(0.03)

# decrease the alpha of the spell if not fully transparent already
func modulate_alpha_down(decrease_amt: float):
	$Sprite2D.modulate.a = $Sprite2D.modulate.a - decrease_amt
	if $Sprite2D.modulate.a < 0:
		$Sprite2D.modulate.a = 0

# resets the alpha to normal
func reset_modulate_alpha():
	$Sprite2D.modulate.a = 1

# will increase the scale of the shatter reaction, then validate such that it doesnt get too big
func increase_scale(growth_float: float):
	self.scale = self.scale + Vector2(growth_float, growth_float)

# clear if longer than .2 s
func _on_timer_timeout():
	my_parent.queue_free()

# on dmg time out increase the scale, move to parent, and do damage
func _on_dmg_timer_timeout() -> void:
	reset_modulate_alpha()
	increase_scale(0.4)
	damage_overlapping_bodies()

# will damage overlapping bodies
func damage_overlapping_bodies():
	for body in get_overlapping_bodies():
		if body.is_in_group("monsters"):
			damage_enemy(body)

# will damage an enemy
func damage_enemy(enemy):
	enemy._hit(dmg, "sunder", "construct", my_parent.spell_caster)

# on body enter
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("monsters"):
		damage_enemy(body)

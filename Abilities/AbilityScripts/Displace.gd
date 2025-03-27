class_name DisplaceAbility extends FlowAbility

# Initial creation of object on load.
func init(skill_dict: Dictionary, cast_target: Vector2, caster: Node2D):
	$AnimatedSprite2D.set_sprite_frames(CustomResourceLoader.displaceSpriteRes)
	myModifiers.append(CollisionDespawnModifier.new())
	super.init(skill_dict, cast_target, caster)

# Handles the reaction effects.
func handle_reaction(reactant: Node2D):
	super(reactant)
	create_new_reaction(reactant)
	
# Handles collision when enemy is hit.
func handle_enemy_interaction(enemy: Enemy):
	enemy._hit(self.dmg, self.element, self.element, self.spell_caster)
	if not enemy.cc_immune:
		if enemy is Monster:
			enemy.can_move = false
		enemy.velocity = velocity.normalized() * 100
		attach_and_await_stun_timer(0.5, enemy)
	despawn()

# create a timer and add to unstun the enemy
func attach_and_await_stun_timer(wait_time: float, enemy: Node2D):
	var timer = Timer.new()
	timer.wait_time = wait_time
	# add the function to be run on timeout
	timer.connect("timeout", Callable(func():
		if enemy is Monster:
			enemy.can_move = true
		enemy.velocity = Vector2.ZERO
		timer.queue_free()))
	enemy.add_sibling(timer)
	timer.start()

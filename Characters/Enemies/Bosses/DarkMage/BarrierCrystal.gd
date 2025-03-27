extends Enemy

signal destroyed_crystal

var invincible := false

func _ready():
	# my health
	health = 50
	# max health
	maxHealth = 50
	cc_immune = true

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	pass

# hit by something
func _hit(dmg_to_take, dmg_type_1, dmg_type_2, caster):
	if not invincible:
		# Reduce my hp
		health -= dmg_to_take
		
		# Spawn damage number
		var dmgNum = damageNumber.instantiate()
		dmgNum.set_colors(AbilityColor.get_color_by_string(dmg_type_1), AbilityColor.get_color_by_string(dmg_type_2))
		get_parent().add_child(dmgNum)
		dmgNum.set_value_and_pos(dmg_to_take, self.global_position)
		
		if health <= 0:
			die()


# when i die
func die():
	# Turn off collision
	set_collision_layer_value(2, false) #enemies
	set_collision_layer_value(4, false) #characters
	invincible = true
	
	# Start fireworks
	$GPUParticles2D.emitting = true
	var tween = create_tween()
	tween.tween_property($Sprite2D, "self_modulate", Color(1,1,1,0), $GPUParticles2D.lifetime).set_ease(Tween.EASE_IN)
	await get_tree().create_timer($GPUParticles2D.lifetime/2)
	
	emit_signal("destroyed_crystal")
	await tween.finished
	queue_free()

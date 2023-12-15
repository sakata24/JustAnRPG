extends Node

var shatterScene = preload("res://Abilities/Reactions/Shatter.tscn")
var singularityScene = preload("res://Abilities/Reactions/Singularity.tscn")
var extinctionScene = preload("res://Abilities/Reactions/Extinction.tscn")
var skillDict = {}

func _ready():
	var dict = {}
	var file = FileAccess.open("res://Resources/abilitysheet.txt", FileAccess.READ)
	var content = file.get_as_text()
	skillDict = JSON.parse_string(content)["skills"]
	file.close()
	pass

# returns the skill requested
func _get_ability(skill):
	return skillDict[skill]

# make a timer that ticks. ability is a reference, tick is how often
func start_tick_timer(ability, tick):
	var timer = Timer.new()
	timer.wait_time = tick
	ability.add_child(timer)
	while true:
		timer.start()
		ability.set_collision_mask_value(2, true)
		await timer.timeout
		timer.start()
		ability.set_collision_mask_value(2, false)
		await timer.timeout
	timer.queue_free()

# performs action of ability on spawn
func perform_spawn(ability, pos, caster):
	match ability.abilityID:
		"cell":
			var timer = Timer.new()
			timer.wait_time = 0.05
			ability.add_child(timer)
			
			timer.start()
			while true:
				print("beeg")
				ability.scale *= 1.1
				ability.dmg += 1
				await timer.timeout
				timer.start()
			timer.queue_free()
		"vine":
			ability.modulate.a = 1.0
			var vectorArray = PackedVector2Array([
				Vector2(0, -0.4),
				Vector2(0, 0.4),
				Vector2(8 * ability.size, 0.4),
				Vector2(8 * ability.size, -0.4)
			])
			ability.get_node("Texture").set_polygon(vectorArray)
			ability.get_node("CollisionPolygon2D").set_polygon(vectorArray)
			ability.position = clamp_vector(pos, caster.global_position, 10)
			ability.look_at(pos)
		"fountain":
			ability.modulate.a = 0.5
			ability.set_collision_mask_value(2, false)
		"suspend":
			ability.modulate.a = 0.5
			start_tick_timer(ability, 0.13)
		"fissure":
			ability.modulate.a = 0.5
			ability.set_collision_mask_value(2, false)
			# setting hitbox
			var vectorArray = PackedVector2Array([
				Vector2(0, -3),
				Vector2(0, 3),
				Vector2(8 * ability.size, 3),
				Vector2(8 * ability.size, -3)
			])
			ability.get_node("Texture").set_polygon(vectorArray)
			ability.get_node("CollisionPolygon2D").set_polygon(vectorArray)
			ability.position = clamp_vector(pos, caster.global_position, 10)
			ability.look_at(pos)
		"storm":
			ability.modulate.a = 0.5
			ability.disconnect("body_entered", ability._on_SpellBody_body_entered)
			var timer = Timer.new()
			timer.wait_time = 0.5
			ability.add_child(timer)
			timer.start()
			while true:
				# randomly select someone to damage. more enemies = more attacks = less dmg
				if ability.has_overlapping_bodies():
					var array = []
					for body in ability.get_overlapping_bodies():
						if body.is_in_group("monsters"):
							array.push_back(body)
					if not array.is_empty():
						var enemy = array[randi() % array.size()]
						enemy._hit(floor(ability.dmg/(array.size()+1)), ability.get_node("Texture").color)
						timer.wait_time = (0.9/(array.size()+1))
				await timer.timeout
				timer.start()
			timer.queue_free()
		_:
			print("nothing")

func clamp_vector(vector, clamp_origin, clamp_length):
	var offset = (vector - clamp_origin) * 10000
	return clamp_origin + offset.limit_length(clamp_length)

# performs action of an ability on timeout
func perform_timeout(ability):
	match ability.abilityID:
		"bolt":
			print("BOOM")
		"crack":
			ability.set_collision_mask_value(2, false)
			ability.modulate.a = 0.2
		"charge":
			ability.speed = 1.4 * 300
			ability.dmg = ability.dmg * 1.5
			ability.scale = ability.scale * 1.5
		"rock":
			print("*falling rock noises*")
		"cell":
			print("im grass")
		"fountain":
			print("woosh")
			ability.modulate.a = 0.8
			ability.set_collision_mask_value(2, true)
		"suspend":
			print("fade")
			ability.modulate.a = 0.3
		"fissure":
			ability.modulate.a = 0.7
			start_tick_timer(ability, 0.5)
		_:
			print("nothing")

# performs action of an ability before despawn
func perform_despawn(ability):
	match ability.abilityID:
		_:
			print("simple despawn")
	ability.queue_free()

func perform_reaction(collider, collided):
	print("reaction with " + collider.element + " + " + collided.element)
	# pause timers if reaction so it may complete
	collided.get_node("TimeoutTimer").paused = true
	collided.get_node("LifetimeTimer").paused = true
	match collider.element + collided.element:
		"construct" + "sunder":
			# SHATTER: Disable construct ability and create an explosion
			var shatter = shatterScene.instantiate()
			shatter.parent = collider
			shatter.dmg = collided.dmg + collider.dmg
			collider.scale = Vector2(1,1)
			collider.add_child(shatter)
			collider.get_node("CollisionPolygon2D").disabled = true
			collider.get_node("Texture").visible = false
			collider.speed = collided.speed * 0.2
			collided.get_node("TimeoutTimer").paused = false
			collided.get_node("LifetimeTimer").paused = false
		"sunder" + "construct":
			# SHATTER: Disable construct ability and create an explosion
			var shatter = shatterScene.instantiate()
			shatter.parent = collided
			shatter.dmg = collider.dmg + collider.dmg
			collided.scale = Vector2(1,1)
			collided.add_child(shatter)
			collided.get_node("CollisionPolygon2D").disabled = true
			collided.get_node("Texture").visible = false
			collided.speed = collided.speed * 0.2
			collider.get_node("TimeoutTimer").paused = false
			collider.get_node("LifetimeTimer").paused = false
		"growth" + "construct":
			# VINE: Transform type of spell to growth
			collided.element = "growth"
			collided.canReact = true
			collided.get_node("Texture").color = Color("#70ad47")
		"sunder" + "wither":
			# SINGULARITY: Suck in enemies to center
			print("penis")
			collided.get_node("TimeoutTimer").paused = false
			collided.get_node("LifetimeTimer").paused = false
			var singularity = singularityScene.instantiate()
			singularity.parent = collided
			collided.add_child(singularity)
		"construct" + "wither":
			# EXTINCTION: Execute enemies
			collided.get_node("TimeoutTimer").paused = false
			collided.get_node("LifetimeTimer").paused = false
			var extinction = extinctionScene.instantiate()
			collided.add_child(extinction)
		"growth" + "wither":
			# EXTEND: Greatly increase lifetime of both spells
			collided.get_node("LifetimeTimer").wait_time = collided.get_node("LifetimeTimer").wait_time * 1.5
			collider.get_node("LifetimeTimer").wait_time = collider.get_node("LifetimeTimer").wait_time * 1.5
			collided.get_node("TimeoutTimer").wait_time = collided.get_node("TimeoutTimer").wait_time * 1.5
			collider.get_node("TimeoutTimer").wait_time = collider.get_node("TimeoutTimer").wait_time * 1.5
			collided.get_node("TimeoutTimer").start()
			collider.get_node("TimeoutTimer").start()
		_:
			collided.get_node("TimeoutTimer").paused = false
			collided.get_node("LifetimeTimer").paused = false
	

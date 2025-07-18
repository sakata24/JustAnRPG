class_name LuminousEye extends Boss

var photon_laser_scene = load("res://Abilities/BossMoves/LuminousEye/PhotonLaser.tscn")
var photon_bullet_scene = load("res://Abilities/BossMoves/LuminousEye/PhotonBullet.tscn")
var mirror_resource = load("res://Maps/MapElements/BossMapElements/LuminousMirror.tscn")
var barrier_pickup_scene = load("res://Interactables/Boss/BarrierPickup.tscn")
var laser_audio = preload("res://Resources/audio/sfx/laser.ogg")

var time: float
var mirror_spawn_area: Rect2 = Rect2()
var protected = false
var stage = 1
var cone_size = (PI/4.0)
@onready var dodecahedron_sprite = $DodecahedronSprite

func _ready():
	maxHealth = 750
	health = 750
	boss_name = "Photonis, the Luminous Eye"
	super._ready()
	randomize_mirrors()

# photon bullets - summons a cone of bullets
func summon_photon_bullets(num: int, bounces: int):
	var delta = cone_size/(num-1)
	for i in range(0, num):
		var spawn_angle = ($ProjectilePivot.rotation - cone_size/2.0) + (delta * i)
		var spawn_pos = Vector2(cos(spawn_angle), sin(spawn_angle)) * $ProjectilePivot/SpellSpawnPos.position
		var photon_bullet: PhotonBullet = photon_bullet_scene.instantiate()
		photon_bullet.connect("attack_finished", $StateMachine/Attack._on_attack_finished)
		add_child(photon_bullet)
		photon_bullet.position = spawn_pos
		photon_bullet.rotation = spawn_angle
		photon_bullet.collision_count = bounces
	

# photon laser - a laser that bounces off of mirrors
func cast_photon_laser(bounces: int):
	var photon_laser: PhotonLaser = photon_laser_scene.instantiate()
	add_child(photon_laser)
	if stage == 3:
		photon_laser.get_node("LaserTimer").wait_time = 0.7
	photon_laser.connect("attack_finished", $StateMachine/Attack._on_attack_finished)
	photon_laser.connect("firing_laser", play_laser_audio)
	photon_laser.charge(player.global_position)
	
# fractal barrier - makes the boss immune to damage until shield is broken
func enable_fractal_barrier():
	dodecahedron_sprite.modulate = Color(0.8, 0.745, 0.416, 0.8)
	spawn_barrier_pickup()
	protected = true

func fractal_barrier_broken():
	dodecahedron_sprite.modulate = Color(1, 1, 1, 0.47)
	protected = false

func spawn_barrier_pickup():
	var rand_pos = 48 * Vector2(randi_range(1, 32), randi_range(1, 7))
	var barrier_pickup: BarrierPickup = barrier_pickup_scene.instantiate()
	add_sibling(barrier_pickup)
	barrier_pickup.global_position = rand_pos

# parallax ability - teleports the boss to a new location
func change_position():
	# blind player
	var color_rect = ColorRect.new()
	player.get_node("Camera2D").add_child(color_rect)
	color_rect.size.x = player.get_viewport_rect().size.x
	color_rect.size.y = player.get_viewport_rect().size.y
	color_rect.position.x = -color_rect.size.x/2.0
	color_rect.position.y = -color_rect.size.y/2.0
	color_rect.z_index = 2
	color_rect.color = Color(0, 0, 0)
	var blind_timer = Timer.new()
	blind_timer.connect("timeout", func(): 
		color_rect.queue_free())
	blind_timer.connect("timeout", $StateMachine/Attack._on_attack_finished)
	blind_timer.wait_time = 0.2
	color_rect.add_child(blind_timer)
	blind_timer.start()
	# teleport
	var new_pos = randi_range(100, 1435)
	position.x = new_pos
	# randomize mirrors
	randomize_mirrors()

# hall of versailles - change the location of the mirrors
func randomize_mirrors():
	for mirror in get_tree().get_nodes_in_group("mirrors"):
		mirror.queue_free()
	var mirror_pos_list = []
	for i in range(0, 17):
		var new_mirror: LuminousMirror = mirror_resource.instantiate()
		new_mirror.mirror = MirrorType.new()
		call_deferred("add_sibling", new_mirror)
		var rand_pos = 48 * Vector2(randi_range(1, 31), randi_range(1, 7))
		# ensure mirror is not on the boss or on other mirrors
		while (rand_pos.distance_to(self.get_global_position()*(48 * 3)) < 200) or (rand_pos.distance_to(player.get_global_position()*(48 * 3)) < 100) or (mirror_pos_list.has(str(rand_pos.x) + "|" + str(rand_pos.y))):
			rand_pos = 48 * Vector2(randi_range(1, 31), randi_range(1, 7))
		mirror_pos_list.append(str(rand_pos.x) + "|" + str(rand_pos.y))
		new_mirror.global_position = rand_pos
		new_mirror.mirror.facing = MirrorType.variant.values().pick_random()
		new_mirror.add_to_group("mirrors")

func hit(damage: DamageObject):
	if not protected:
		super(damage)
		if stage == 1 and health < maxHealth * 0.667:
			stage = 2
			change_position()
			cone_size = PI/3.0
			enable_fractal_barrier()
			$IdleTimer.wait_time = 2.4
		if stage == 2 and health < maxHealth * 0.333:
			stage = 3
			change_position()
			cone_size = PI/2.0
			enable_fractal_barrier()
			$IdleTimer.wait_time = 1.3
		if health <= 0:
			die()
	elif damage.get_types().has("fracture"):
		fractal_barrier_broken()
	else:
		var dmgNum = damageNumber.instantiate()
		dmgNum.set_colors(AbilityColor.get_color_by_string(damage.get_type(0)), AbilityColor.get_color_by_string(damage.get_type(1)))
		get_parent().add_child(dmgNum)
		dmgNum.set_value_and_pos("Immune", self.global_position)
		# Update UI
		emit_signal("health_changed", health, true)

# override so i just chill in the center and float
func _physics_process(delta: float) -> void:
	time += delta
	position.y += sin(time * 2.5) * 0.1
	$EyeSprite.position.y += sin((time + 0.5) * 2.5) * 0.07

func play_laser_audio() -> void:
	$AudioStreamPlayer2D.set_stream(laser_audio)
	$AudioStreamPlayer2D.play()

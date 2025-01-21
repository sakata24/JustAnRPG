extends Monster

var stage = 0
var invincible := true

signal health_changed

# Set the stats of the boss
func _ready():
	speed = 50
	baseSpeed = 50
	health = 500
	maxHealth = 500
	add_to_group("monsters")
	call_deferred("_set_player")

# Connect the player reference as well as the HUD
func _set_player():
	player = get_parent().get_parent().get_parent().get_node("Player")
	var HUD = player.get_parent().get_node("HUD")
	connect("health_changed", HUD._on_boss_health_change)
	HUD.show_boss_bar("Dread Warden", health)
	emit_signal("health_changed", maxHealth, true)
	aggro = true
	$PathTimer.start()

# chases the player
func chase(delta):
	var new_velocity = to_local($NavigationAgent2D.get_next_path_position()).normalized() * speed
	print(str(global_position) + " " + str($NavigationAgent2D.target_position) + " " + str(new_velocity))
	if new_velocity.x < 0:
		$Sprite2D.flip_h = true
	elif new_velocity.x > 0:
		$Sprite2D.flip_h = false
	set_velocity(new_velocity)

func _on_path_timer_timeout():
	$NavigationAgent2D.target_position = player.global_position

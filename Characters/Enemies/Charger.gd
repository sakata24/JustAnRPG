extends "res://Characters/Enemies/Monster.gd"

var lockTarget
var dashing = 0

# make the monster move
func _physics_process(delta):
	if aggro and not attacking and not dashing:
		self.rotation = lerp_angle(self.rotation, self.global_position.angle_to_point(player.position), 0.1)
		chase(delta)
	else:
		if dashing:
			print(lockTarget)
			set_velocity(position.direction_to(lockTarget) * speed * 4.5)
			move_and_slide()
			

# chases the player
func chase(delta):
	if position.distance_to(player.position) > 75:
		set_velocity(position.direction_to(player.position) * speed)
		move_and_slide()
	else:
		attacking = true
		lockTarget = (player.position-self.position) * 3 * player.position
		$DamageArea.look_at(lockTarget)
		$DamageArea.visible = true
		$AttackTimer.start()

func _on_attack_timer_timeout():
	dashing = true
	$DamageArea.visible = false
	$DashTimer.start()


func _on_dash_timer_timeout():
	dashing = false
	attacking = false
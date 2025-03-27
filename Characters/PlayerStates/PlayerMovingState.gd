class_name PlayerMovingState extends State

@export var player: Player
@onready var animation: AnimatedSprite2D = player.get_node("AnimatedSprite2D")

func enter():
	animation.set_animation("walk")
	animation.set_frame_and_progress(animation.get_frame(), animation.frame_progress)
	handle_move_event()

func exit():
	pass

func update(delta: float):
	pass

func physics_update(delta: float):
	handle_movement(delta)
	if Input.is_action_just_pressed('R-Click'):
		handle_move_event()
	if Input.is_action_just_pressed('Space') and player.canDash:
		Transitioned.emit(self, "Dashing")
	if player.canCast:
		if Input.is_action_just_pressed('Q') and await player.cast_ability(0):
			Transitioned.emit(self, "Casting")
		if Input.is_action_just_pressed('W') and await player.cast_ability(1):
			Transitioned.emit(self, "Casting")
		if Input.is_action_just_pressed('E') and await player.cast_ability(2):
			Transitioned.emit(self, "Casting")
		if Input.is_action_just_pressed('R') and await player.cast_ability(3):
			Transitioned.emit(self, "Casting")

func handle_move_event():
	player.moving = true
	player.get_node("NavigationAgent2D").target_position = player.get_global_mouse_position()
	player.emit_signal("moving_to")

func handle_movement(delta):
	player.move_target = player.get_node("NavigationAgent2D").get_next_path_position()
	
	player.speed = player.max_speed
	
	# calculates movement and direction
	player.movement = player.position.direction_to(player.move_target) * player.speed
	player.move_dir = rad_to_deg(player.move_target.angle_to_point(player.position))
	
	player.choose_sprite_direction()
	
	# do we need to move more or not
	if player.position.distance_to(player.get_node("NavigationAgent2D").get_next_path_position()) > 5:
		player.set_velocity(player.movement)
		player.move_and_slide()
		player.movement = player.velocity
	else:
		player.moving = false
		Transitioned.emit(self, "Idle")

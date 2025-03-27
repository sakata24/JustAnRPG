class_name PlayerIdleState extends State

@export var player: Player
@onready var animation: AnimatedSprite2D = player.get_node("AnimatedSprite2D")

func enter():
	animation.set_animation("idle")
	animation.set_frame_and_progress(animation.get_frame(), animation.frame_progress)

func exit():
	pass

func update(delta: float):
	pass

func physics_update(delta: float):
	if Input.is_action_just_pressed('R-Click'):
		Transitioned.emit(self, "Moving")
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

class_name PlayerCastingState extends State

@export var cast_time: float = 0.5
@export var player: Player
@onready var animation: AnimatedSprite2D = player.get_node("AnimatedSprite2D")

func enter():
	animation.set_animation("cast")
	animation.sprite_frames.set_animation_speed("cast", 1.0 / cast_time)
	var cast_anim_timer = Timer.new()
	cast_anim_timer.wait_time = cast_time
	cast_anim_timer.one_shot = true
	cast_anim_timer.connect("timeout", _on_cast_anim_timer_timeout)
	add_child(cast_anim_timer)
	cast_anim_timer.start()
	player.velocity = Vector2.ZERO

func physics_update(delta):
	if Input.is_action_pressed('Space') and player.canDash:
		Transitioned.emit(self, "Dashing")

func _on_cast_anim_timer_timeout():
	player.casting = false
	if player.velocity > Vector2.ZERO:
		Transitioned.emit(self, "Moving")
	else:
		Transitioned.emit(self, "Idle")

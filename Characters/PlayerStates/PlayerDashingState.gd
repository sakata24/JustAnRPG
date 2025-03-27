class_name PlayerDashingState extends State

var dashScene = load("res://Abilities/Dash.tscn")

@export var player: Player
@onready var animation: AnimatedSprite2D = player.get_node("AnimatedSprite2D")

func enter():
	# disable collision w enemy
	player.set_collision_mask_value(4, false)
	# start the cooldown
	var dash_timer = Timer.new()
	dash_timer.wait_time = 5.0
	dash_timer.one_shot = true
	dash_timer.connect("timeout", _on_dash_timer_timeout)
	add_child(dash_timer)
	dash_timer.start()
	# toggle the dash variable
	player.dashing = true
	# execute the dash
	player.move_target = player.get_global_mouse_position()
	handle_dash_animation()

func exit():
	player.set_collision_mask_value(4, true)

func update(delta: float):
	pass

func physics_update(delta: float):
	var offset = (player.move_target - player.global_position).normalized() * 58
	player.move_and_collide(offset)
	Transitioned.emit(self, "Moving")
	player.canDash = false

func handle_dash_animation():
	# instantiate the dash anim
	var dash_anim = dashScene.instantiate()
	# place the dash animation
	var offset = (player.move_target - player.global_position).normalized() * 34
	dash_anim.position = player.global_position + offset
	# aim the dash anim at the dash mouse
	dash_anim.look_at(player.get_global_mouse_position())
	# spawn the anim
	get_parent().add_child(dash_anim)

func _on_dash_timer_timeout():
	player.canDash = true

class_name MonsterAttackingState extends State

@export var monster: Monster
var chase_target: CharacterBody2D
@onready var animation: AnimatedSprite2D = monster.get_node("AnimatedSprite2D")

func enter():
	show_damage_area()
	animation.set_animation("windup")
	animation.play()
	var attack_timer = Timer.new()
	attack_timer.wait_time = monster.attack_timer_time
	add_child(attack_timer)
	attack_timer.name = "attack_timer"
	attack_timer.connect("timeout", on_attack_timer_timeout)
	attack_timer.start()

func exit():
	get_node("attack_timer").queue_free()
	monster.get_node("DamageArea/Indicator").visible = false

func physics_update(delta: float):
	if !monster.can_move:
		Transitioned.emit(self, "Stunned")
		return
	monster.set_velocity(Vector2.ZERO)

func show_damage_area():
	monster.get_node("DamageArea/Indicator").visible = true
	monster.get_node("DamageArea").look_at(chase_target.position)

func on_attack_timer_timeout():
	get_node("attack_timer").queue_free()
	animation.set_animation("attack")
	animation.play()
	for entity: PhysicsBody2D in monster.get_node("DamageArea").get_overlapping_bodies():
		if entity and !entity.is_in_group("monsters"):
			entity.hit(monster.my_dmg)
	Transitioned.emit(self, "Reeling")

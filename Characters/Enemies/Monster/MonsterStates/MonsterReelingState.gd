class_name MonsterReelingState extends State

@export var monster: Monster

func enter():
	var reeling_timer = Timer.new()
	reeling_timer.wait_time = monster.attack_timer_time
	add_child(reeling_timer)
	reeling_timer.name = "reeling_timer"
	reeling_timer.connect("timeout", on_reeling_timer_timeout)
	reeling_timer.start()

func physics_update(delta):
	pass

func on_reeling_timer_timeout():
	get_node("reeling_timer").queue_free()
	Transitioned.emit(self, "Chase")

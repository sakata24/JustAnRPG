class_name BarrierPickup extends Area2D

var barrier_buff_scene = load("res://Interactables/Boss/BarrierBuff.tscn")

var interval = 0.002

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Texture.color.a = $Texture.color.a + interval
	if $Texture.color.a > 0.4:
		interval = -0.002
	elif $Texture.color.a < 0.1:
		interval = 0.002

func _on_body_entered(body: Node2D) -> void:
	if get_parent().has_node("LuminousEye") and (body is Player):
		var barrier_buff = barrier_buff_scene.instantiate()
		body.call_deferred("add_child", barrier_buff)
		barrier_buff.get_node("Timer").connect("timeout", get_parent().get_node("LuminousEye").spawn_barrier_pickup)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	$PlayerNotification.visible = false

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	$PlayerNotification.visible = true

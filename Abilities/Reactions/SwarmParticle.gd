class_name SwarmParticle extends Area2D

func _on_body_entered(body: Monster) -> void:
	if body.is_in_group("monsters"):
		#body._hit()
		pass

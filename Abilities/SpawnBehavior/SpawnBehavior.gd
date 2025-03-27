class_name SpawnBehavior extends Resource

func apply(spell: BaseTypeAbility, cast_target: Vector2):
	pass

static func get_spawn_behavior_object_by_name(name: String):
	match name:
		"cursor": return CursorSpawnBehavior.new()
		"focus": return FocusSpawnBehavior.new()
		"clamp": return ClampSpawnBehavior.new()

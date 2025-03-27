class_name ClampSpawnBehavior extends SpawnBehavior

func apply(spell: BaseTypeAbility, cast_target: Vector2):
	var offset = (cast_target - spell.spell_caster.position).normalized() * spell.CLAMP_DISTANCE
	spell.position = spell.spell_caster.position + offset
	spell.look_at(cast_target)

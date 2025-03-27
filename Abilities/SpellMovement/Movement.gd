class_name Movement extends Node

# to be overridden. Moves the given spell with a velocity.
func apply_movement(ability: BaseTypeAbility, delta: float):
	pass

static func get_movement_object_by_name(name: String):
	match name:
		"bullet": return BulletMovement.new()
		"still" : return StillMovement.new()
		"homing" : return HomingMovement.new()
		_: return Movement.new()

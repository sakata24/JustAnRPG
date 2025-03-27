# A representation of damage in this game with simple getters and setters

class_name DamageObject extends Node

var value = 0
var types = []
var source = null

func init(init_value=0, init_types=[], init_source=null):
	self.value = init_value
	self.types = init_types
	self.source = init_source

func get_value() -> int:
	return self.value

func get_types() -> Array:
	return self.types

func get_source():
	return self.source

func has_types() -> bool:
	if types.len() > 0:
		return true
	else:
		return false

func has_source() -> bool:
	if source != null:
		return true
	else:
		return false

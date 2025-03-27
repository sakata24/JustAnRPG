class_name PlayerCamera extends Camera2D
# taken from Gwizz: https://www.youtube.com/watch?v=LGt-jjVf-ZU

@export var random_str: float = 10.0
@export var shake_fade: float = 6.0

var rng = RandomNumberGenerator.new()

var shake_str: float = 0.0

func apply_shake():
	shake_str = random_str

func _process(delta):
	if shake_str > 0:
		shake_str = lerpf(shake_str, 0, shake_fade * delta)
		
		offset = random_offset()

func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_str, shake_str), rng.randf_range(-shake_str, shake_str))

class_name Trail extends Line2D

@onready var curve := Curve2D.new()
@export var MAX_POINTS : int = 200
var started = false

func _ready():
	started = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if started:
		curve.add_point(get_parent().global_position)
		if curve.get_baked_points().size() > MAX_POINTS:
			curve.remove_point(0)
		points = curve.get_baked_points()
